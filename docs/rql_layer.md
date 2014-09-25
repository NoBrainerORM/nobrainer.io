---
layout: docs
title: RQL Layer
prev_section: caching
next_section: atomic_ops
permalink: /rql_layer/
---

NoBrainer gives you a lot of sugar so you do not have to write RQL queries
yourself. But to really leverage the power of RethinkDB, it is sometimes
necessary to go down to the RQL interface. This section describes how
to mix RQL statements with NoBrainer.

## Running RQL

NoBrainer exposes a `run` method to run arbitrary RQL command through the
[query runner middlewares](https://github.com/nviennot/nobrainer/tree/master/lib/no_brainer/query_runner).
The following shows an example of the usage of `NoBrainer.run`

{% highlight ruby %}
# These three statements are equivalent:
User.count
NoBrainer.run(User.rql_table.count)
NoBrainer.run { |r| r.table('users').count }
{% endhighlight %}

Notice that `NoBrainer.run` can either take the RQL query as an argument or as a
block. When passing a block, you get the [`r`](http://www.rethinkdb.com/api/ruby/#r)
RQL shortcut passed in.

## Run Options

`NoBrainer.run` also accepts options to be passed in the RQL
[`r.run()`](http://www.rethinkdb.com/api/ruby/run/) command:

{% highlight ruby %}
NoBrainer.run(:profile => true) { |r| r.table('users').count }
{% endhighlight %}

Because running queries with certain options is useful (profiling, durability,
etc.), NoBrainer provides a method `NoBrainer.with()` which specifies what options
to run the RQL queries with. For example:

{% highlight ruby %}
NoBrainer.with(:use_outdated => true) do
  User.each { ... }
end
{% endhighlight %}

`NoBrainer.with()` will pass options to the run RQL command. To understand
the implications of this, consider the following example:

{% highlight ruby %}
criteria = NoBrainer.with(:use_outdated => true) { User.all }
criteria.count
{% endhighlight %}

The criteria will not use the provided run options, because the RQL command is
actually ran when calling `count`, which is outside the `NoBrainer.with()` block.
It is a bad practice to return criteria from a `NoBrainer.with()`
block. More information can be found in the [Multi Tenancy](/docs/multi_tenancy) section.

`NoBrainer.with()` can be nested, and is thread safe.

## Generating RQL from NoBrainer

You can access the RQL table of a model with `User.rql_table`. Such method
would return by default `r.table('users')`, but can be overriden by the
`store_in` method described in the multi tenancy section.

When using a criteria, you may use `criteria.to_rql` to retrieve the RQL query
that would be performed. For example:

{% highlight ruby %}
NoBrainer.run { User.where(:name => /john/).to_rql.count }
{% endhighlight %}

## Instantiating Models

When running raw RQL queries, you may get documents back in an attribute hash
format. You may use `Model.new_from_db(attrs)` to instantiate a model with
attributes coming from the database. When using polymorphism, any class in
the hierarchy will do.
