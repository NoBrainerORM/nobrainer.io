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
* `Model.create(attrs)` calls `Model.new(attrs)` and then `save`
* `Model.create!(attrs)` calls `Model.new(attrs)` and then `save!`
* `Model.insert_all(doc1, doc2, ..., docN)` is used for bulk inserts. This method
  receives a list of hashes, and will not instantiate any models. Instead it
  passes the document hashes in bulk to the database to perform efficient writes.
* `Model.sync` is a wrapper for [`r.sync()`](http://www.rethinkdb.com/api/ruby/#sync).

The following predicates are available on a model instance:

* `new_record?` returns true if the instance has not yet been persisted
* `destroyed?` returns true if the instance has been destroyed
* `persisted?` returns true if the instance has been persisted and not destroyed.

The following methods are available on a model instance:

* `save` returns true if the instance was valid and saved, otherwise false.
* `save!` calls `save` and raises `NoBrainer::Error::DocumentInvalid` if `save` returned false.
* `update_attributes()` calls `assign_attributes()` and `save`
* `update_attributes!()` calls `assign_attributes()` and `save!`
* `update(&block)` performs an update on the instance with a given RQL
  lambda expression. This can be interesting to perform atomic operations.
  Example: `instance.update { |doc| { :field1 => doc[:field1] * 1 } }`.  
  The syntax can be found on the [RethinkDB docs](http://www.rethinkdb.com/api/ruby/update/).
  You need to call `reload` on your model to be able to read the updated fields.
* `replace(&block)` performs a replacement on the instance document. This is
  different from `update()` as update works more like a merge.
  Refer to the [RethinkDB docs](http://www.rethinkdb.com/api/ruby/replace/) for more information.
* `delete` removes the document from the database without firing the destroy
  callbacks.
* `destroy` fires the destroy callbacks and removes the document from the database.
* `reload` removes any instance variables that the instance may have to nuke any
  sort of cache. `reload` then loads a fresh record from the database.
  You may pass an option `:keep_ivars => true` to prevent `reload` from cleaning
  up the instance variables. A `NoBrainer::Error::DocumentNotFound` error will
  be raised if the document can no longer be found.

Neither `update()`, `replace()`, `delete`, `destroy`, `save`, `save!` will raise.
These methods will silently fail if the document is no longer in the database
while it was supposed to be. If you have the need to detect such occurrences,
please create an issue on Github.

NoBrainer will never autosave a model behind the scene. When working with a
database that does not support transactions, you need to be in full control of
when database writes occur. There is therefore no autosave features in NoBrainer
and all the writes need to be explicit.

Database writes can also be performed on criteria with `update_all()`,
`replace_all()`, `delete_all` and `destroy_all`.
Learn more in the [querying section](/docs/querying).
