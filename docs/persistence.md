---
layout: docs
title: Persistence
permalink: /persistence/
---

## Persistence API

NoBrainer provides a similar persistence interface compared to other ORMs.

The following methods are available on the `Model` class:

* `Model.new(attrs)` instantiate a new Model instance. Default values are set
  and `attrs` is passed to `assign_attributes`.
* `Model.create(attrs)` calls `Model.new(attrs)` and then `save`.
* `Model.create!(attrs)` calls `Model.new(attrs)` and then `save!`.
* `upsert`, `upsert!`, `first_or_create` and `first_or_create!`: see below.
* `Model.insert_all([doc1, doc2, ..., docN])` is used for bulk inserts. This method
  receives a list of hashes, and will not instantiate any models. Instead it
  passes the documents in bulk to the database to perform efficient writes.
  If the documents primary keys are left unspecified, the database will assign
  default UUIDs and `insert_all` will return the list of generated ids.
  You may use `NoBrainer::Document::PrimaryKey::Generator.generate` to generate
  MongoDB style ids to match the format of model instances.
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

## upsert

NoBrainer provides an API to fetch and update a record, or create it if not
found. This is done atomically. Validations are The usage is shown as below:

{% highlight ruby %}
instance = Model.upsert(attrs)
unless instance.errors.present?
  # validations failed when creating or updating the instance
end

instance = Model.upsert!(attrs) # raises when validations fail.
{% endhighlight %}

Note that NoBrainer will need to match either the primary key in attrs, or a
field that has a uniqueness validator as the `upsert` uses
the `first_or_create` mechanism  as described below.

## first_or_create

NoBrainer provides an API to fetch a record, or create a record if not found.
This is done atomically. The usage is shown below:

{% highlight ruby %}
# passing params inline
doc = Model.where(some_condition).first_or_create!(additional_params)

# passing params within a block
doc = Model.where(some_condition).first_or_create! do
  # Only called if where().first was not found.
  additional_params
end
{% endhighlight %}

NoBrainer performs the following stpes:

1. A lock around `some_condition` is acquired.
2. If `where(some_condition).first` matches a document, the lock is released and
   the document is returned.
3. Otherwise, `Model.create(some_condition.merge(additional_params))` is
   performed, and the lock is released right after the persistance operation.

`some_condition` must match a defined uniqueness validator to enforce the
atomicity properly. NoBrainer will provide helpful error message if it cannot
find any. This ensure that `first_or_create()` does not race with any other
`create()` operations.

This API comes in two flavors. `first_or_create()` does not raise an exception
when validation fails, while `first_or_create!()` does.

## Optimized Updates

When using updating a model, NoBrainer uses the [dirty tracking](/docs/dirty_tracking)
information to only update the fields that changed. When no attribute changed,
the database update query is skipped, but all callbacks are still executed.
