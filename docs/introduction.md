---
layout: docs
title: Introduction
next_section: differences_from_other_orms
permalink: /introduction/
---


NoBrainer is an ORM for [RethinkDB](http://rethinkdb.com).
The goal of NoBrainer is to provide a similar interface compared to ActiveRecord
and Mongoid to build data models on top of RethinkDB. Nevertheless, NoBrainer
breaks a couple of established patterns to provide a consistent API. You may
read more about these differences in the [next
section](/docs/differences_from_other_orms/).

## Dependencies

NoBrainer depends on a couple of things:

* The RethinkDB database.
* NoBrainer runs on Ruby MRI 1.9.3+, Ruby MRI 2.x, JRuby in 1.9+ mode.
* NoBrainer can be used without Rails, but plays nicely with Rails3 and Rails4.
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

* Leverage indexes for comparison operators (using `between()`).
* Support Field types, especially dealing with array, hashes and sets.
* Support different way to store times (utc or timezoned).
* Support for instrumentation such as New Relic.
* Support joins.
* Dirty tracking should track changes in hashes.
* Use dirty tracking to do efficient updates.
* Support for field aliases and/or custom primary key names.
* Support for read-only fields.
* Support some form of single embedded documents (some sort of nice wrapper for hashes).
* Implement the associated validator.
* Generic "polymorphic" support for `belongs_to` associations.
* Give some progress bars on the indexing, and also countdowns/confirmation before dropping indexes.
* Support `pluck()`, `without()`.
* Accept multiple database connections strings for failovers.

## Changelog

### git HEAD

* Fixed a `NameError` bug when trying to include the `DynamicAttributes` module.
Issue: [#54](https://github.com/nviennot/nobrainer/issues/54).

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
