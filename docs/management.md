---
layout: docs
title: Management
prev_section: indexes
next_section: multi_tenancy
permalink: /management/
---

NoBrainer comes with helpers to manage the RethinkDB database.

## Managing Databases

NoBrainer comes with a couple of helper methods to manage the database:

* `NoBrainer.drop!` drops the current database.
* `NoBrainer.purge!` truncates all the tables in the database.
* `NoBrainer.sync_schema` configures the tables and synchronizes the indexes.

## When Running Tests

When running tests, it is important to have an easy way to cleanup the database.
`NoBrainer.purge!` will truncate all the existing tables leaving the index
declarations. This is much faster compared to the `NoBrainer.drop!` command, which
drops the database entirely.

When running tests, it is recommanded to do the following:

* Run `NoBrainer.sync_schema` before running all tests.
* Run `NoBrainer.purge!` before each tests.

## Rake Tasks

When using Rails, NoBrainer implements a few rake tasks:

{% highlight bash %}
$ rake nobrainer:drop         # Drop the database
$ rake nobrainer:sync_schema  # Synchronize the schema
$ rake nobrainer:seed         # Load seed data from db/seeds.rb
$ rake nobrainer:setup        # Equivalent to :sync_schema + :seed
$ rake nobrainer:reset        # Equivalent to :drop + :setup
{% endhighlight %}

## Accessing System Tables

NoBrainer provides models to access RethinkDB system tables.
The models are the following:

* `NoBrainer::System::DBConfig`
* `NoBrainer::System::ClusterConfig`
* `NoBrainer::System::ServerConfig`
* `NoBrainer::System::ServerStatus`
* `NoBrainer::System::TableConfig`
* `NoBrainer::System::TableStatus`
* `NoBrainer::System::Issue`
* `NoBrainer::System::Job`
* `NoBrainer::System::Log`
* `NoBrainer::System::Stat`

Further, `Model.table_status` returns the corresponding `TableStatus` instance
of the model table. `Model.table_config` and `Model.table_stats`
returns the table config and stats of the model table.

## Rebalancing a Table

* `Model.rebalance` initiates the rebalancing of the table.
* `Model.table_wait` waits for the table to be ready.

## Connection

NoBrainer manages a driver-level connection to RethinkDB.
`NoBrainer.connection.raw` retrieves the managed RethinkDB connection.
`NoBrainer.disconnect` disconnects the connection if connected.

NoBrainer automatically disconnects the connection on forks, so you do not have
worry when using gems such as Unicorn or Resque. However, if some threads
are running queries during the fork, there will be issues since the connection
is disconnected pre-fork.

NoBrainer uses a single RethinkDB connection by default, which slows down
performance in multi threaded applications, but is the safest solution
until connection pools are implemented.
You may set `config.per_thread_connection` to `true` to avoid a performance hit
in multi threaded applications. Calling `NoBrainer.disconnect` before exiting a
thread is a good idea to avoid resource exhaustion.

NoBrainer automatically reconnects to the database when the connection has been lost.
Specifically, when the database connection is lost while running a query,
NoBrainer tries to reconnect and re-issue the query every second until it succeed.
NoBrainer gives up after 15 tries (configurable with the `max_retries_on_connection_failure` setting).
This behavior may be a concern for non idempotent write queries. If such retries can be
an issue, setting `max_retries_on_connection_failure` to `0` will disable
query retries on connection failures.
Losing the connection while iterating a cursor (e.g. with `each`) will not
trigger a retry but raise a lost connection exception, except on the
first iteration which acquires the database cursor.
