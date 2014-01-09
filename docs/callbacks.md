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

2. Validation is performed after the `before_save/create/update` callbacks.
In other words, validation is performed right before the data is about
to be persisted to the database. This decision was made because it became
a common pattern to use `before_save` callbacks to set attributes instead of
`before_validation`. It does not make much sense to validate the model data
before changing it. This behavior has the drawback of having non validated data
present while running before callbacks.  This downside is not so bad because in
this case, the persist operation is likely to fail anyway.

3. The `initialize` callbacks are also triggered during `reload`.

## Orders of Callbacks

The following describes the order of callbacks:

* When a document is initialized with `new`, or when loaded from the database,
  or reinitialized with `reload`:

  * `before_initialize`
  * document is (re-)initialized
  * `after_initialize`

* When a new document is persisted with save:

  * `before_save`
  * `before_create`
  * `before_validation`
  * `after_validation`
  * document is inserted
  * `after_create`
  * `after_save`

* When an existing document is updated with save:

  * `before_save`
  * `before_update`
  * `before_validation`
  * `after_validation`
  * document is updated
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
