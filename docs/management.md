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

NoBrainer will automatically disconnect the connection on forks, so you do not have
worry when using gems such as Unicorn or Resque. However, if you have some
threads running some queries while you are forking in another thread, you may
have issues since the connection is disconnected pre-fork.
Please post an issue on Github if that's a problem for you.

NoBrainer uses a single RethinkDB connection, which is thread safe
and used efficiently in a multi threaded environment.
Threads send requests by writing directly on the socket, but never block the
socket when waiting for data to be received. Instead, the RethinkDB gem
spawns a listener thread on the connection, parses the responses, and
wake up the appropriate thread waiting on its data.

## Managing Databases

NoBrainer comes with a couple of helper methods to manage databases that simply
wraps the RQL equivalents:
* `NoBrainer.db_create("db_name")` creates the database `db_name`.
* `NoBrainer.db_drop("db_name")` drops the database `db_name`.
* `NoBrainer.db_list` lists the databases.

Similarly, NoBrainer allows access to tables with the following wrappers:
* `NoBrainer.table_create("table_name")` creates the table `table_name`.
* `NoBrainer.table_drop("table_name")` drops the table `table_name`.
* `NoBrainer.table_list` lists the tables.

If you need helpers to create all the tables of your models with some sort of
rake command because you are not using the auto table create feature, please
create an issue on Github.

## Cleaning Up

When running tests, it is important to have an easy way to cleanup the database.
`NoBrainer.purge!` will truncate all the existing tables leaving the index
declarations. This is much faster compared to the `NoBrainer.drop!` command, which
drops the database entirely. When running tests, using `NoBrainer.purge!` before
each tests is recommended. Do not forget to `NoBrainer.update_indexes` before
your test suite.

## Managing Indexes

Explained in the [indexes section](/docs/indexes).

## Rake Tasks

When using Rails, NoBrainer implements a few rake tasks:

{% highlight bash %}
rake db:drop           # Drop the database
rake db:update_indexes # Create and drop indexes on the database
rake db:seed           # Load seed data from db/seeds.rb
rake db:setup          # Equivalent to db:update_indexes + db:seed
rake db:reset          # Equivalent to db:drop + db:setup
{% endhighlight %}

If you are using both ActiveRecord and NoBrainer, they will probably conflict on
the rake tasks, so it might be better to not use them for now. In the future
NoBrainer will be a little more considerate.

Note that NoBrainer relies on the configuration settings `auto_create_databases`
and `auto_create_tables` to create the database and tables. In the future,
NoBrainer will explicitly create the database and tables.
