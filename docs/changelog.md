---
layout: docs
title: Changelog
prev_section: roadmap
next_section: 3rd_party_integration
permalink: /changelog/
---

### HEAD

* Added support for distributed locks when performing uniqueness validations.
* Removed the `document.attributes=` accessor.
* Bug fix: document dirtiness is now properly cleaned after a database read.
* `Symbol` typed fields are now read back from the database as symbols and not strings.
* Bug fix: `before_validation` callbacks no longer stop the validation chain when returning `false`.
* Added support for Rails 4.1.

### 0.13.0 -- Jan. 12th 2014

* Removed `update()` and `replace()` for the model instance.
* Removed `inc_all()` and `dec_all()` for criteria.
* Reinstantiating a instance model from the database no longer goes through the
  setters to keep things consistent with the rest of the API.
* Dirty tracking tracks changes from an undefined field, to a field set to `nil`.
* Hashes are updated with `r.literal()` to avoid the use of `replace`.
* Added a `:required => true` options on fields as a shorthand for the presence validation.
* Improved the reconnection mechanism.
* Added support for readonly fields.
* Removed Rails3 compatibility.

### 0.12.0 -- Jan. 8th 2014

* Timestamps are no longer enabled by default.
* `where()` validates and casts all the values with respect to their declared
  field types. This avoid potential query injections.
* Saving a model will only update the attributes that have changed. No database
  update will be performed in case nothing has changed.
* `after_find()` callbacks are available on models, and also on criteria.
* Removed `.to_xml`. This feature is still available by including a module.
* License changed from MIT to LGPLv3.

### 0.11.0 -- Jan. 7th 2014

* Using indexes for `gt`, `gte`, `lt`, `lte` operators when possible.
* Renamed `criteria.includes()` to `criteria.preload()`.
* Added a `:validates` option on fields.
* Fixed dirty tracking with mutable values such as hashes and array.
* Added `initialize` callbacks.
* Boolean types adds a `field_name?` method for convenience.

### 0.10.0 -- Jan. 6th 2014

* Fixed a `NameError` bug when trying to include the `DynamicAttributes` module.
Issue: [#54](https://github.com/nviennot/nobrainer/issues/54).
* Make the associations hackable.
* Implementation of the type checking/casting mechanism.

### 0.9.1 -- Jan. 5th 2014

* Added Rails generators for models
* Removed unecessary ActiveSupport requires.

### 0.9.0 -- Jan. 5th 2014

* Removed the `auto_include_timestamps` and `include_root_in_json` settings.
  Because The order in which the models are declared and NoBrainer configured affected
  the result. Related issue [#52](https://github.com/nviennot/nobrainer/issues/52)
* Removed the `cache_documents` setting because it should not be broken.
* Bug fix with `order_by()` which would try to use an index after a RQL
  `filter()` or `get_all()`.
* `includes()` no longer kill the criteria cache.
* Loading a `has_many` association will set the corresponding
  `belongs_to` association, with or without eager loading.
* Added the `has_many through` association. The implementation is done through
  eager loading.
* Added the `has_one` association.
* Renamed `with_options()` -> `with()`.

### 0.8.0 -- Dec. 31st 2013

* First documented release of NoBrainer.
