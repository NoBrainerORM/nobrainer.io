---
layout: docs
title: Management
prev_section: indexes
next_section: multi_tenancy
permalink: /management/
---

NoBrainer comes with helpers to manage the RethinkDB database.

## Connection

`NoBrainer.connection` retrieves a connected connection. NoBrainer will first connect
if no connection is established yet.
`NoBrainer.disconnect` disconnects if connected.

NoBrainer automatically disconnects the connection on forks, so you do not have
worry when using gems such as Unicorn or Resque. However, if some threads
are running queries during the fork, there will be issues since the connection
is disconnected pre-fork.

NoBrainer uses a single RethinkDB connection, which is thread safe
and used efficiently in a multi threaded environment.
Threads send requests by writing directly on the socket, but never block the
socket when waiting for data to be received. Instead, the RethinkDB gem
spawns a listener thread on the connection, parses the responses, and
wake up the appropriate thread waiting on its data.

NoBrainer automatically reconnects to the database when the connection has been lost.
Specifically, when the database connection is lost while running a query,
NoBrainer tries to reconnect and re-issue the query every second until it succeed.
NoBrainer gives up after 10 tries (configurable with the `max_reconnection_tries` setting).
This behavior may be a concern for non idempotent write queries. If reconnections are
potentially an issue, setting `max_reconnection_tries` to `0` will disable
automatic reconnections.
Losing the connection while iterating a cursor (e.g. with `each`) will not
trigger a reconnection but raise a lost connection exception, except on the
first iteration which acquires the cursor.

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

* Run `NoBrainer.update_indexes` before running all tests.
* Run `NoBrainer.purge!` before each tests.

## Managing Indexes

Index management is explained in the [Indexes](/docs/indexes) section.

## Rake Tasks

When using Rails, NoBrainer implements a few rake tasks:

{% highlight bash %}
rake db:drop           # Drop the database
rake db:update_indexes # Create and drop indexes on the database
rake db:seed           # Load seed data from db/seeds.rb
rake db:setup          # Equivalent to db:update_indexes + db:seed
rake db:reset          # Equivalent to db:drop + db:setup
{% endhighlight %}

If you are using both ActiveRecord and NoBrainer, the two ORMs will conflict on
the rake tasks, so it might be better to not use both ORMs in the same application.
You may configure NoBrainer with `warn_on_active_record` to `false` to shut down warnings
related to such usage pattern.

Note that NoBrainer relies on the configuration settings `auto_create_databases`
and `auto_create_tables` to create the database and tables. In the future,
NoBrainer will explicitly create the database and tables.
