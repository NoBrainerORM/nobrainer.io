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

* `changed_attributes` returns a hash of the form `{attr => old_value}`.
* `changed?` returns a boolean whether the instance changed.
* `changed` returns an array of attribute names which have changed.
* `changes` returns a hash of the form `{attr => [old_value, new_value]}`
* `previous_changes` returns the previous changes done. This is useful if you
  want to access to changes in `after_*` callbacks.

You have access to the following methods for each defined attribute:

* `attr_changed?` returns a boolean if `attr` changed.
* `attr_change` returns an array `[old_value, new_value]`.
* `attr_was` returns the old value of `attr`.

Field default value assignments (e.g. `field :name, :default => 'hello'`)
register their changes. In fact, the dirty tracking starts as soon as the model
is instantiated or read from the database.
Once the model is saved, the dirty tracking is reset. In some ways,
the dirty tracking computes a diff from the content in the database to the
model instance.

Dirty tracking does not work yet when it comes to hash and array fields.
Dirty tracking assumes that you will assign a field when you will change it.
This will be fixed in the future.

NoBrainer does not use dirty tracking to do efficient model updates yet.
