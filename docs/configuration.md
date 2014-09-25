---
layout: docs
title: Configuration
prev_section: differences_from_other_orms
next_section: models
permalink: /configuration/
---

NoBrainer can be configured by calling `NoBrainer.configure { }`.  
With a Rails application, you may place this configuration block in an
initializer, such as `config/initializers/nobrainer.rb`.
The settings are shown with their default values:

{% highlight ruby %}
NoBrainer.configure do |config|
  # The rethinkdb_url specifies the RethinkDB database connection url.
  # When left unspecified, NoBrainer picks a database connection by default.
  # The default is to use localhost, with a database name matching the
  # Rails application name and the Rails environment.
  # NoBrainer also reads environment variables when defined:
  # * RETHINKDB_URL, RDB_URL
  # * RETHINKDB_HOST, RETHINKDB_PORT, RETHINKDB_DB, RETHINKDB_AUTH
  # * RDB_HOST, RDB_PORT, RDB_DB, RDB_AUTH
  # config.rethinkdb_url = config.default_rethinkdb_url

  # NoBrainer uses logger to emit debugging information.
  # The default logger is the Rails logger if run with Rails,
  # otherwise Logger.new(STDERR) with a WARN level.
  # If the logger is configured with a DEBUG level,
  # then each database query is emitted.
  # config.logger = config.default_logger

  # NoBrainer will colorize the queries if colorize_logger is true.
  # Specifically, NoBrainer will colorize management RQL queries in yellow,
  # write queries in red and read queries in green.
  # config.colorize_logger = true

  # You probably do not want to use both NoBrainer and ActiveRecord in your
  # application. NoBrainer will emit a warning if you do so.
  # You can turn off the warning if you want to use both.
  # config.warn_on_active_record = true

  # auto_create_databases allows NoBrainer to create databases on demand.
  # This behavior is similar to MongoDB.
  # config.auto_create_databases = true

  # auto_create_tables allows NoBrainer to create tables on demand.
  # This behavior is similar to MongoDB.
  # Note that this will not auto create indexes for you.
  # You still need to run `rake db:update_indexes` to create the indexes.
  # config.auto_create_tables = true

  # When the network connection is lost, NoBrainer will try running a given
  # query 10 times before giving up. Note that this can be a problem with non
  # idempotent write queries such as increments.
  # Setting it to 0 disable reconnections.
  # config.max_reconnection_tries = 10

  # Configures the durability for database writes.
  # The default durability is :hard, unless when running with Rails in test or
  # development mode, for which the durability mode is :soft.
  # config.durability = config.default_durability

  # user_timezone can be configured with :utc, :local, or :unchanged.
  # When reading an attribute from a model which type is Time, the timezone
  # of that time is translated according to this setting.
  # config.user_timezone = :local

  # db_timezone can be configured with :utc, :local, or :unchanged.
  # When writting to the database, the timezone of Time attributes are
  # translated according to this setting.
  # config.db_timezone = :utc

  # Configures which mechanism to use in order to perform non-racy uniqueness
  # validations. Read more about this behavior in the validation section.
  # config.distributed_lock_class = nil

  # Instead of using a single connection to the database, You can tell
  # NoBrainer to spin up a new connection for each thread. This is
  # useful for multi-threading usage such as Sidekiq.
  # Call NoBrainer.disconnect before a thread exits, otherwise you will have
  # a resource leak, and you will run out of connections.
  # Note that this is solution is temporary, until we get a real connection pool.
  # config.per_thread_connection = false
end
{% endhighlight %}

Removing ActiveRecord with Rails
--------------------------------

NoBrainer can coexist with ActiveRecord at runtime, but the two conflict on
rake tasks. It's best to remove ActiveRecord unless you plan to use both SQL
and RethinkDB in your application.

### With a fresh Rails app

If your Rails application is not yet created, you can create your rails app with:

{% highlight bash %}
rails new app_name --skip-active-record
{% endhighlight %}

### With an existing Rails app

To remove ActiveRecord from an existing Rails application, three steps must be done:

1) Open `config/application.rb`. On line 3, replace `require 'rails/all'` with:

{% highlight ruby %}
# require 'active_record/railtie'
require 'action_controller/railtie'
require 'action_mailer/railtie'
require 'sprockets/railtie'
require 'rails/test_unit/railtie'
{% endhighlight %}

2) Comment all the configuration options in `config/environments/*.rb` that
contains `active_record`.

3) Remove `config/database.yml`, and anything in `db/` except `db/seeds.rb`.

ActiveRecord with NoBrainer
---------------------------

As mentioned before, if ActiveRecord is present with NoBrainer there will be a
conflict with the built in rake tasks and Rails generators. To get around this,
prefix the `active_record` namespace before the generator name:

{% highlight bash %}
rails g active_record:migration migration_name
{% endhighlight %}
