---
layout: docs
title: Multi Tenancy
prev_section: management
next_section: communication
permalink: /multi_tenancy/
---

NoBrainer supports multi tenancy features. These features are for
advanced users that understand the behavior of NoBrainer, especially the
[RQL layer](/docs/rql_layer), and the [caching behavior](/docs/caching).
NoBrainer provides two different ways to perform multi tenancy:
1. Using a `with_database` block.
2. Using a `store_in` model declaration.

## Changing databases at the connection level

You may use `NoBrainer.with_database` to change the default database to use on
the connection.

{% highlight ruby %}
NoBrainer.with_database('client1')
  Project.each { ... }
end
{% endhighlight %}

`NoBrainer.with_database(name)` is an alias for
`NoBrainer.with(:db => name)`, which can be seen as a thread safe
version of the [`r.use()`](http://www.rethinkdb.com/api/ruby/#use).
This means that all the rules of `NoBrainer.with` applies. Specifically, you
should never leak a criteria outside a `with_database()` block. For example:

{% highlight ruby %}
criteria = NoBrainer.with_database('client1') { Project.all }
criteria.first # Will not read the client1 projects.
{% endhighlight %}

The `with_database()` takes effect only when a RQL query is executed.
Criteria are not aware of such multi tenancy features, and will behave
as expected with respect to caching. For example:

{% highlight ruby %}
# Creating a criteria instance.
criteria = Project.all

# The following each query caches the documents on criteria.
NoBrainer.with_database('client1') { criteria.each { ... } }

# The following does not returns clients2 projects, but client1 projects
# because of caching side effects.
NoBrainer.with_database('client2') { criteria.each { ... } } 
{% endhighlight %}

Note that `with_database()` can be nested, and is thread safe.

**TL;DR** do not leak criteria out of `with_database()` blocks.

Typically, `with_database()` blocks are implemented as around filters on
controllers, or rack middlewares.

## Model specific database behavior

With NoBrainer you may specify which Model gets stored where with the `store_in`
declaration. For example, to store the User model in `some_table` in `some_db`:

{% highlight ruby %}
class User
  store_in :database => 'some_db', :table => 'some_table'
end
{% endhighlight %}

It is much more interesting to use lazily evaluated lambdas. For example:

{% highlight ruby %}
class User
  store_in :database => ->{ "#{Thread.current[:client]}" }
end
{% endhighlight %}

Now, the User database is defined dynamically, depending on the content of
`Thread.current[:client]`. We could have also defined the table name in the same
way. 

The lambda is evaluated when compiling the criteria down to a RQL expression.
Calling `User.rql_table` or `User.all.to_rql` will evaluate the lambda. This is
because instead of using a connection option, the database and table names are
directly embedded in the RQL query using the
[`r.db()`](http://www.rethinkdb.com/api/ruby/#db) and
[`r.table()`](http://www.rethinkdb.com/api/ruby/#table) commands. This allow the
power to hit multiple databases within the same query by, for example, using joins.
The following shows an example of using the previous `store_in` declaration:

{% highlight ruby %}
Thread.current[:client] = 'client1'
User.rql_table # r.db('client1').table('users')
User.all.count # NoBrainer.run { r.db('client1').table('users').count }
{% endhighlight %}

If you mix `NoBrainer.with_database` and `store_in` declaration, the
latter has precedence on the former as you would expect. As a word of warning,
please understand what you are doing, things can get hairy very quickly.

If you want to test your lambdas, you can read the used database and table names
with `Model.database_name` and `Model.table_name`. If `Model.database_name`
returns `nil`, the `r.db()` command will not be inserted in generated RQL
queries and the default connection database name will be used when running
the RQL query as explained earlier.
