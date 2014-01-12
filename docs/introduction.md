---
layout: docs
title: Introduction
next_section: differences_from_other_orms
permalink: /introduction/
---


NoBrainer is an ORM for [RethinkDB](http://rethinkdb.com).
The goal of NoBrainer is to provide a similar interface compared to ActiveRecord
and Mongoid to build data models on top of RethinkDB while providing precise
semantics.
Nevertheless, NoBrainer breaks a couple of established patterns to provide a
consistent API. You may read more about these differences in the [next
section](/docs/differences_from_other_orms/).

NoBrainer is written and maintained by <a href="https://twitter.com/nviennot">Nicolas Viennot</a>.

## Dependencies

NoBrainer depends on a couple of things:

* The RethinkDB database.
* NoBrainer runs on Ruby MRI 1.9.3+, Ruby MRI 2.x, JRuby in 1.9+ mode.
* NoBrainer does not depend on Rails, but plays nicely with Rails 4.
* NoBrainer depends on the [`rethinkdb`](https://rubygems.org/gems/rethinkdb),
      [`activemodel`](https://github.com/rails/rails/tree/master/activemodel),
      [`activesupport`](https://github.com/rails/rails/tree/master/activesupport),
      [`middleware`](https://github.com/mitchellh/middleware) gems.
      These dependencies are automatically pulled in when you install the
      `nobrainer` gem.

When running on Heroku, the RethinkDB database connection string is auto-detected.

## Quick Start

The following assume you are using a Rails application, and that you are running a
RethinkDB instance locally.

---

To install NoBrainer, add the `nobrainer` gem in your `Gemfile` and `bundle install`:

{% highlight ruby %}
# Gemfile
gem 'nobrainer'
{% endhighlight %}

When using NoBrainer with Rails, NoBrainer comes with a set of default
settings that allow you to start using NoBrainer right away without making any
further [configuration](/docs/configuration) or database migrations.

---

Declare a model in `app/models/user.rb`:

{% highlight ruby %}
class User
  include NoBrainer::Document
  field :name
  field :email
end
{% endhighlight %}

---

In a Rails console, you can create models which will be persisted to the database:

{% highlight ruby %}
User.create(:name => 'Nico', :email => 'nicolas@viennot.biz')
User.count # returns 1
{% endhighlight %}

---

A Rails application example using NoBrainer can be found
[here](https://github.com/rethinkdb/rails-nobrainer-blog/).

## Roadmap

The roadmap is the following. Items at the beginning of the list are somewhat higher priority.

* Support queuable atomic operations.
* Support query keywords in nested documents to allow queries such as:  
  `User.where(:address => { :zipcode.not => 1024 })`.
* Support for field aliases.
* Support custom primary key names.
* Support `pluck()`, `without()`.
* Support different way to store times (utc or timezoned).
* Support joins.
* Give some progress bars on the indexing, and also countdowns/confirmation before dropping indexes.
* Support type definitions like `{String => Integer}`.
* Support for instrumentation hooks such as New Relic.
* Support generic "polymorphic" support for `belongs_to` associations as opposed to STI.
* Support embedded documents. Embedding should be done by using the type system like regular fields.
* Accept multiple database connections strings for failovers.
* Rake tasks should explicitly create database/tables
* Make NoBrainer really fast.

## Changelog

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
