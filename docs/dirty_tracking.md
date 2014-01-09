---
layout: docs
title: Dirty Tracking
prev_section: validations
next_section: associations
permalink: /dirty_tracking/
---

## Dirty Tracking

NoBrainer tracks changes on model attributes. You can access the following
methods on a model instance. These methods register changes for both
declared fields and dynamic attributes.

* `changed?` returns a whether the instance changed.
* `changed` returns an array of attribute names which have changed.
* `changes` returns a hash of the form `{attr => [old_value, new_value]}`.

You have access to the following methods for each defined attribute:

* `attr_changed?` returns a whether `attr` changed.
* `attr_change` returns an array `[old_value, new_value]`.
* `attr_was` returns the old value of `attr`.

Field default value assignments (e.g. `field :name, :default => 'hello'`)
register their changes. In fact, the dirty tracking starts as soon as the model
is instantiated or read from the database.
Once the model is saved, the dirty tracking is reset. In some ways,
the dirty tracking computes a diff from the content in the database with
the in memory model instance.

When a field was not previously set, and then set to `nil`, NoBrainer will
report no change even though the value has technically changed.
This is a bit sad, but there is no `undefined` value in Ruby like in
javascript. If you'd like to make a suggestion, please open a Github issue :)

NoBrainer uses dirty tracking to do efficient model updates. Only the
attributes that changed are sent to the database. Read more about
this behavior in the [Persistence section](/docs/persistence) and
its quirks.
