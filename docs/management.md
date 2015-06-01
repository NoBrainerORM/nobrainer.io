---
layout: docs
title: Management
prev_section: indexes
next_section: multi_tenancy
permalink: /management/
---

NoBrainer comes with helpers to manage the RethinkDB database.

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

## Managing Databases

NoBrainer comes with a couple of helper methods to manage databases that simply
wraps the RQL equivalents:

* `NoBrainer.db_list` lists the databases.
* `NoBrainer.db_create("db_name")` creates the database `db_name`.
* `NoBrainer.db_drop("db_name")` drops the database `db_name`.
* `NoBrainer.drop!` drops the current database. Read also about `purge!` below.

Similarly, NoBrainer allows access to tables with the following wrappers:

* `NoBrainer.table_list` lists the tables.
* `NoBrainer.table_create("table_name")` creates the table `table_name`.
* `NoBrainer.table_drop("table_name")` drops the table `table_name`.

If you need helpers to create all the tables of your models with some sort of
rake command because you are not using the auto table create feature, please
create an issue on GitHub.

## Cleaning Up

When running tests, it is important to have an easy way to cleanup the database.
`NoBrainer.purge!` will truncate all the existing tables leaving the index
declarations. This is much faster compared to the `NoBrainer.drop!` command, which
drops the database entirely.

When running tests, it is recommanded to do the following:

* Run `NoBrainer.sync_indexes` before running all tests.
* Run `NoBrainer.purge!` before each tests.

## Managing Indexes

Index management is explained in the [Indexes](/docs/indexes) section.

## Rake Tasks

When using Rails, NoBrainer implements a few rake tasks:

{% highlight bash %}
rake nobrainer:drop         # Drop the database
rake nobrainer:sync_indexes # Synchronize indexes definitions
rake nobrainer:seed         # Load seed data from db/seeds.rb
rake nobrainer:setup        # Equivalent to :sync_indexes_quiet + :seed
rake nobrainer:reset        # Equivalent to :drop + :setup
{% endhighlight %}
