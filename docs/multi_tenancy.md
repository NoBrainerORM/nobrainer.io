---
layout: docs
title: Multi Tenancy
permalink: /multi_tenancy/
---

## Changing databases at the connection level

You may use `NoBrainer.run_with(:db => 'db_name')` to change the default database to use on
the connection.

{% highlight ruby %}
NoBrainer.run_with(:db => 'client1') do
  Project.each { ... }
end
{% endhighlight %}

Typically, `run_with()` blocks are implemented as around filters on
controllers, or rack middlewares.

## Model specific behavior

With NoBrainer you may specify which Model gets stored where with the `table_config`
declaration. For example, to store the User model in `some_table`:

{% highlight ruby %}
class Project
  table_config :name => 'some_table'
end
{% endhighlight %}

You may also use lazily evaluated lambdas. For example:

{% highlight ruby %}
class Project
  table_config :name => ->{ "project_#{Thread.current[:client]}" }
end
{% endhighlight %}

For introspection, you may use `Model.table_name` to retreive the computed table
name.

## Managing Databases

NoBrainer does not automatically create indexes when auto creating a database
or table. To create the indexes on a custom database, you may use the following:

{% highlight ruby %}
NoBrainer.run_with(:db => 'db_name') { NoBrainer.sync_schema }
{% endhighlight %}

Make sure all your models are loaded before calling `sync_schema` if you are
not using Rails.
