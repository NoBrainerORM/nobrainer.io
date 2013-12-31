---
layout: docs
title: Callbacks
prev_section: persistence
next_section: validations
permalink: /callbacks/
---

## Declaring callbacks

To declare callbacks, NoBrainer follows the same calling convention as other
ORMs. Typically:

{% highlight ruby %}
class Model
  after_save { puts "Saved!" }
  after_save :say_hello

  def hello
    puts 'hello'
  end
end
{% endhighlight %}

## Differences with other ORMs

NoBrainer does not stick to the traditional callback implementation. The
callback behavior in NoBrainer differs in two ways compared to most ORMs:

1. Returning `false` in a `before_*` callback does not halt the chain.
This way you will not halt the chain by mistake when using with boolean
attributes. You can always raise an exception, or add an error to the `errors`
array if you intent to halt the chain.

2. Validation is performed after the `before_save/create/update` callbacks.
In other words, validation is performed right before the data is about
to be persisted to the database. This decision was made because it became
a common pattern to use `before_save` callbacks to set attributes instead of
`before_validation`. It does not make much sense to validate the model data
before changing it. This behavior has the drawback of having non validated data
present while running before callbacks.  This downside is not so bad because in
this case, the persist operation is likely to fail anyway.

## Orders of Callbacks

The following describes the order of callbacks.

When a document is created and persisted for the first time in the database the
following callbacks are run (create):

* `before_save`
* `before_create`
* `before_validation`
* `after_validation`
* (document is inserted)
* `after_create`
* `after_save`

When an existing document is updated with save (update):

* `before_save`
* `before_update`
* `before_validation`
* `after_validation`
* (document is updated)
* `after_update`
* `after_save`

When an existing document is destroyed:

* `before_destroy`
* (document is deleted)
* `after_destroy`

There is no `after_initialize` nor `after_find` callbacks. If you need such
callbacks, please make a request on Github.
