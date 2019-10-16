---
layout: docs
title: Event Machine
permalink: /docs/event_machine/
---

At the moment, the RethinkDB Ruby driver only supports EventMachine for
asynchronous operations. NoBrainer supports EventMachine through the use of Ruby
Fibers to keep its synchronous API semantics similarly to
[em-synchrony](https://github.com/igrigorik/em-synchrony).

## Configuration

The following shows how to configure NoBrainer to use EventMachine:

{% highlight ruby %}
NoBrainer.configure do |config|
  config.driver = :em # Queries are run through the EventMachine driver.
end
{% endhighlight %}

## Semantics

* All NoBrainer queries must be run within a Fiber.
* NoBrainer provides a `close()` method on returned cursors to cancel streams.

## Example

A full example can be found in the [recipes section](/docs/real_time_tutorial/).
