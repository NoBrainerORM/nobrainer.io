---
layout: docs
title: Differences from other ORMs
prev_section: introduction
next_section: configuration
permalink: /differences_from_other_orms/
---

NoBrainer breaks a couple of established patterns to provide a consistent API
with semantics as precise as possible.

* RethinkDB does not support transactions, so you need to be in control of when
  a database write happens. NoBrainer never autosaves a model behind the scenes.
* `has_many` associations are read-only. Writable `has_many` associations are
  leaky abstractions and are thus not implemented to keep sane semantics.
  Therefore there is no `has_and_belongs_to_many` associations. Read the
  [Associations](/docs/associations) section on how to create your own join table.
* Returning false in a `before_*` callback does not halt the chain. If you want
  to abort the chain, you must be explicit by raising an exception or
  adding an error to the model in the case of a `before_validation` callback.
* The latest `order_by()` wins when chaining queries.
* Specifying types on fields introduces safe type casting and performs automatic
  validations in models and queries.
* `instance.reload` will also clear all the instance variable of an instance and
  call `initialize()` again.
* Uniqueness validators can leverage distributed locks to provide race-free
  semantics. This feature is crucial when using sharded databases such as RethinkDB
  as secondary indexes do not provide uniqueness guarantees.
* Declaring an index with `multi => true` does not change the behavior of
  queries, unlike Mongoid. When the `any` keyword is used (e.g.
  `Post.where(:tags.any => 'programming')`), NoBrainer uses a multi
  index if declared, but otherwise falls back to generating a suitable RQL code.
