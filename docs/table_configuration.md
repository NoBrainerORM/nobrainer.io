---
layout: docs
title: Table Configuration
prev_section: distributed_locks
next_section: indexes
permalink: /table_configuration/
---

## Configuring Tables

To configure table settings globally, you may do so during NoBrainer
configuration:

{% highlight ruby %}
NoBrainer.configure do |config|
  config.table_options = { :shards => 1, :replicas => 1,
                           :write_acks => :majority }
end
{% endhighlight %}

To configure per table settings, you may use `Model.table_config` as such:

{% highlight ruby %}
class Model
  table_config :shards => 2, :replicas => 2,
               :write_acks => :single, :durability => :soft
end
{% endhighlight %}

## Synchronizing table schema

When changing the configuration of tables, the new schema must be reflected on
the database.

When using Rails, you may use the rake task:

{% highlight bash %}
$ rake nobrainer:sync_schema
{% endhighlight %}

You can also update the database schema programmatically:

{% highlight ruby %}
NoBrainer.sync_indexes
{% endhighlight %}

NoBrainer waits for the tables to be ready by default.
You may pass `:wait => false` to `sync_schema` to skip the wait.
