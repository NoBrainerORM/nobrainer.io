---
layout: docs
title: Persistence
prev_section: serialization
next_section: callbacks
permalink: /persistence/
---

## Persistence API

NoBrainer provides a similar persistence interface compared to other ORMs.

The following methods are available on the `Model` class:

* `Model.new(attrs)` instantiate a new Model instance. Default values are set
  and `attrs` is passed to `assign_attributes`.
* `Model.create(attrs)` calls `Model.new(attrs)` and then `save`.
* `Model.create!(attrs)` calls `Model.new(attrs)` and then `save!`.
* `Model.insert_all([doc1, doc2, ..., docN])` is used for bulk inserts. This method
  receives a list of hashes, and will not instantiate any models. Instead it
  passes the documents in bulk to the database to perform efficient writes.
  If the documents primary keys are left unspecified, the database will assign
  default UUIDs and `insert_all` will return the list of generated ids.
  You may use `NoBrainer::Document::Id.generate` to generate MongoDB style ids
  to match the format of model instances.
* `Model.sync` is a wrapper for [`r.sync()`](http://www.rethinkdb.com/api/ruby/#sync).

The following predicates are available on a model instance:

* `new_record?` returns true if the instance has not yet been persisted.
* `destroyed?` returns true if the instance has been destroyed.
* `persisted?` returns true if the instance has been persisted and not destroyed.

The following methods are available on a model instance:

* `save` returns true if the instance was valid and saved, otherwise false.
* `save?` is an alias for `save`.
* `save!` calls `save` and raises `NoBrainer::Error::DocumentInvalid` if `save` returned false.
* `update()` calls `assign_attributes()` and `save`.
* `update?()` is an alias for `update()`.
* `update!` calls `update` and raises `NoBrainer::Error::DocumentInvalid` if `update` returned false.
* `delete` removes the document from the database without firing the destroy
  callbacks.
* `destroy` fires the destroy callbacks and removes the document from the database.
* `reload` removes all instance variables that the instance may have, to nuke any
  sort of cache. `reload` then loads a fresh record from the database and
  calls the `initialize()` method, which triggers the `initialize` callbacks.
  You may pass an option `:keep_ivars => true` to prevent `reload` from cleaning
  up the instance variables.  
  A `NoBrainer::Error::DocumentNotFound` error will be raised if the document
  can no longer be found.

Note that `delete`, `destroy`, or `save` during updates do not raise if the
instance document no longer exists in the database when performing the
operation.  These methods will silently fail.

NoBrainer never autosaves a model behind the scene. When working with a
database that does not support transactions such as RethinkDB, you need to be in
full control of when database writes occur. There is therefore no autosave
features in NoBrainer and all the writes need to be explicit.

Database writes can also be performed on criteria with `update_all()`,
`replace_all()`, `delete_all` and `destroy_all`.
Learn more in the [Querying](/docs/querying) section.

## Optimized Updates

When using updating a model, NoBrainer uses the [dirty tracking](/docs/dirty_tracking)
information to only update the fields that changed. When no attribute changed,
the database update query is skipped, but all callbacks are still executed.
