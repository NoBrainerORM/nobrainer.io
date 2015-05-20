---
layout: docs
title: Callbacks
prev_section: persistence
next_section: validations
permalink: /callbacks/
---

## Declaring Callbacks

To declare callbacks, NoBrainer follows the same calling convention as other
ORMs as it reuses the `ActiveModel` callback logic. Typically:

{% highlight ruby %}
class Model
  include NoBrainer::Document
  field :alive, :type => Boolean

  before_save { puts "going to save!" }
  after_save :say_hello, :if => :alive?

  def say_hello
    puts 'hello'
  end
end
{% endhighlight %}

## Differences with other ORMs

NoBrainer does not stick to the traditional callback implementation. The
callback behavior in NoBrainer differs in three ways compared to most ORMs:

1. Returning `false` in a `before_*` callback does not halt the chain.
This way you will not halt the chain by mistake when using with boolean
attributes. If your intention is to halt the chain, you can always raise an
exception, or add an error to the `instance.errors` array in the case of a
`before_validation` callback.

2. The `initialize` callbacks are also triggered during `reload`.

## Orders of Callbacks

The following describes the order of callbacks:

* When a document is initialized with `new`, or when loaded from the database,
  or reinitialized with `reload`:

  * `before_initialize`
  * document is (re-)initialized
  * `after_initialize`

* When a new document is persisted with save:

  * uniqueness validations locks are acquired
  * `before_validation`
  * `after_validation`
  * `before_save`
  * `before_create`
  * document is inserted
  * uniqueness validations locks are released
  * `after_create`
  * `after_save`

* When an existing document is updated with save:

  * uniqueness validations locks are acquired
  * `before_validation`
  * `after_validation`
  * `before_save`
  * `before_update`
  * document is updated
  * uniqueness validations locks are released
  * `after_update`
  * `after_save`

* When an existing document is destroyed:

  * `before_destroy`
  * document is deleted
  * `after_destroy`

* When a document is fetched from the database:

  * `before_initialize`
  * `after_initialize`
  * `after_find`

The `after_find` callback will not be triggered again when calling `reload` on a model.

The `after_save` and `after_update` callbacks are called on `save` regardless if the
database was updated or not, which may happen when no attribute changed.

`around_*` callbacks are available as usual.
