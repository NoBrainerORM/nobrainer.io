---
layout: docs
title: Differences from other ORMs
prev_section: introduction
next_section: configuration
permalink: /differences_from_other_orms/
---

NoBrainer breaks a couple of established patterns to provide an consistent API
with semantics as precise as possible.

* When using `find()` and no document has been found, NoBrainer will not raise
  an exception, but return `nil`. To get the traditional `find()` ActiveRecord
  behavior, one must use `find!()` which raises when the target is not found.
  This behavior matches the semantics of `first` and `first!`.
* RethinkDB does not support transactions, so you need to be in control of when
  a database write happens. NoBrainer never autosaves a model behind the scenes.
* `has_many` associations are read-only. Writable `has_many` associations are
  leaky abstractions and are thus not implemented to keep sane semantics.
  Therefore there is no `has_and_belongs_to_many` associations. Read the
  [associations section](/docs/associations) on how to create your own join table.
* Upon `save()`, validations are performed after the `before_save` callbacks
  because it became a common pattern to use `before_save` callbacks to modify
  model data. Validations should thus be performed after such callbacks.
* Returning false in a `before_*` callback does not halt the chain. If you want
  to abort the chain, you must be explicit by raising an exception or
  adding an error to the model in the case of a `before_validation` callback.
* The latest `order_by()` wins when chaining queries.
* Specifying types on fields introduces safe type casting and performs automatic
  validations.
* `instance.reload` will also clear all the instance variable of an instance and
  call `initialize()` again.
