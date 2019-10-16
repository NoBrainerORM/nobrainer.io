---
layout: docs
title: Real Time Tutorial
permalink: /docs/real_time_tutorial/
---

The following showcases an example of using RethinkDB, NoBrainer,
[EventMachine](https://github.com/eventmachine/eventmachine),
[Goliath](https://github.com/postrank-labs/goliath) and
[Ruby fibers](http://ruby-doc.org/core-2.2.0/Fiber.html) to
demonstrate RethinkDB real-time features through a simple HTTP interface.

Our application contains 3 files: `Gemfile`, `init.rb` and `app.rb`,
which respectively specify the gems we'll be using, the application
configuration, and the application logic.

## Gemfile

{% highlight ruby %}
source 'https://rubygems.org'
gem 'goliath', '~> 1.0.4'
gem 'nobrainer', '~> 0.29.0'
{% endhighlight %}

## init.rb

{% highlight ruby %}
# First we load our gems.
require 'bundler'
Bundler.require

# Then we configure NoBrainer.
NoBrainer.configure do |config|
  config.app_name = "goliath"
  config.environment = Goliath.env
  config.driver = :em
  config.logger = Logger.new(STDERR).tap { |log| log.level = Logger::DEBUG }
end

# Next, we define a helper method `stream(&block)' that immediately returns
# HTTP headers to the client, and schedule the passed blocked to be ran in a
# Fiber at the next EventMachine tick. Because we must not let any exceptions
# bubble up from the fiber to prevent killing the EventMachine loop, we catch
# them and handle them accordingly in `guard_async_response()'.

module StreamFiber
  def stream(env, &block)
    EM.next_tick { Fiber.new { guard_async_response(env, &block) }.resume }
    chunked_streaming_response
  end

  def guard_async_response(env, &block)
    block.call(env)
  rescue Exception => e
    begin
      msg = {:error => "#{e.class}: #{e.message.split("\n").first}"}
      STDERR.puts msg
      env.chunked_stream_send("#{msg.to_json}\n")
    rescue
    end
  ensure
    env.chunked_stream_close
  end
end

# Then, we introduce a helper to cancel outstanding requests made to the
# database when an HTTP client disconnect.
# `bind_cursor_to_connection(env, cursor)' binds a NoBrainer cursor to an
# HTTP connection, meaning that when the connection gets closed through the
# `on_close()' Goliath callback, `close()' is called on all registered
# cursors.

module BindCursor
  def bind_cursor_to_connection(env, cursor)
    if env['connection_closed']
      cursor.close
    else
      env['cursors'] ||= []
      env['cursors'] << cursor
    end
  end

  def on_close(env)
    env['connection_closed'] = true
    env['cursors'].to_a.each(&:close)
  end
end
{% endhighlight %}

## app.rb

{% highlight ruby %}
require './init'

# We define a simple Item model with two fields: an SKU with a uniqueness
# constraint, and a name.

class Item
  include NoBrainer::Document
  field :sku,  :type => String, :required => true, :uniq => true
  field :name, :type => String
end

# We define our Goliath application which responds to the /upsert and /changes
# endpoints. /upsert simply upserts Items (insert if not found, update if
# found), and /changes opens a firehose emitting changes on the items table.

class App < Goliath::API
  use Goliath::Rack::Params
  include StreamFiber
  include BindCursor

  def upsert(env)
    item = Item.upsert!(env['params'])
    [200, {}, item.to_json]
  end

  def changes(env)
    stream(env) do
      Item.where(env['params']).raw.changes(:include_states => true)
        .tap { |cursor| bind_cursor_to_connection(env, cursor) }
        .each { |changes| env.chunked_stream_send("#{changes.to_json}\n") }
    end
  end

  def response(env)
    case [env['REQUEST_METHOD'].downcase.to_sym, env['PATH_INFO']]
      when [:post, '/upsert']  then upsert(env)
      when [:get,  '/changes'] then changes(env)
      else raise Goliath::Validation::NotFoundError
    end
  end
end
{% endhighlight %}

## Running the Example

When running the server as shown below, we can issue requests on our server.

{% highlight bash %}
$ ruby app.rb -sv
[28846:INFO] 2015-08-17 02:13:51 :: Starting server on 0.0.0.0:9000 in development mode. Watch out for stones.
{% endhighlight %}

### Example 1: Creating a valid Item

{% highlight bash %}
$ curl -X POST localhost:9000/upsert?sku=123\&name=hello
{"id":"2J3EyCBX5JyjIX","name":"hello","sku":"123"}
{% endhighlight %}


### Example 2: Creating an invalid Item

{% highlight bash %}
$ curl -X POST localhost:9000/upsert
[:error, "#<Item id: \"blah\"> is invalid: Sku can't be blank"]
{% endhighlight %}

### Example 3: Modifying items while listening for changes

First we listen for changes:

{% highlight bash %}
$ curl localhost:9000/changes
{"state":"ready"}
{% endhighlight %}

Then we open a new shell and run:
{% highlight bash %}
$ curl -X POST localhost:9000/upsert?sku=456\&name=hello
{"id":"2J3K0C71Nn0RQ6","name":"hello","sku":"456"}
$ curl -X POST localhost:9000/upsert?sku=456\&name=ohai
{"id":"2J3K0C71Nn0RQ6","name":"ohai","sku":"456"}
$ curl -X POST localhost:9000/upsert?sku=456
{"id":"2J3K0C71Nn0RQ6","name":"ohai","sku":"456"}
{% endhighlight %}

We see on previous curl appear:
{% highlight bash %}
$ curl localhost:9000/changes
{"state":"ready"}
{"new_val":{"id":"2J3K0C71Nn0RQ6","name":"hello","sku":"456"},"old_val":null}
{"new_val":{"id":"2J3K0C71Nn0RQ6","name":"ohai","sku":"456"},"old_val":{"id":"2J3K0C71Nn0RQ6","name":"hello","sku":"456"}}
{% endhighlight %}

### Example 4: Listening for changes on a specific subject

{% highlight bash %}
$ curl localhost:9000/changes?sku=222
{% endhighlight %}

{% highlight bash %}
$ curl -X POST localhost:9000/upsert?sku=111
$ curl -X POST localhost:9000/upsert?sku=222
{% endhighlight %}

We only see the changes of the second Item, not the first one.

### Example 5: Running many clients

{% highlight bash %}
$ for i in `seq 10`; do curl -N localhost:9000/changes &; done
{% endhighlight %}

We see 10 times `{"state":"ready"}`

{% highlight bash %}
$ curl -X POST localhost:9000/upsert?sku=333
{% endhighlight %}

We see 10 times `{"new_val":{"id":"2J3MDIpNLPchjS","sku":"333"},"old_val":null}`.

This demonstrate that our server can handle many clients simultaneously.

### Example 6: Handling connection failures

If we kill the RethinkDB server while a `/changes` call is in progress, we see
the following:

{% highlight bash %}
$ curl localhost:9000/changes
{"state":"ready"}
<-- kill the RethinkDB server at this point -->
{"error":"RethinkDB::RqlDriverError: Connection closed by server."}
$ 
{% endhighlight %}

If we re-issue the curl command, our web server rejects immediately our request.

{% highlight bash %}
$ curl localhost:9000/changes
{"error":"RethinkDB::RqlRuntimeError: Connection is closed."}
$
{% endhighlight %}

Once we restart the RethinkDB server, we can reissue requests immediately:

{% highlight bash %}
$ curl localhost:9000/changes
{"state":"ready"}
{% endhighlight %}
