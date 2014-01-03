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

* NoBrainer runs on Ruby MRI 1.9.3+, Ruby MRI 2.x, JRuby in 1.9+ mode.
* NoBrainer can be used without Rails, but plays nicely with Rails3 and Rails4.
* NoBrainer depends on the [`rethinkdb`](https://rubygems.org/gems/rethinkdb),
      [`activemodel`](https://github.com/rails/rails/tree/master/activemodel),
      [`activesupport`](https://github.com/rails/rails/tree/master/activesupport),
      [`middleware`](https://github.com/mitchellh/middleware) gems.
      These dependencies are automatically pulled in when you install the
      `nobrainer` gem.
* The RethinkDB database.

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
  field :name
end
{% endhighlight %}

---

In a Rails console, you can create models which will be persisted to the database:

{% highlight ruby %}
User.create!(:name => 'Maureen')
User.create!(:name => 'Johnny')
User.count # returns 2
{% endhighlight %}

---

A Rails application example using NoBrainer can be found
[here](https://github.com/rethinkdb/rails-nobrainer-blog/).

## Roadmap

The roadmap without order is:

* implement `has_one` association.
* implement `has_many` through association.
* Support `pluck()`, `without()`.
* Field types, especially dealing with array, hashes and sets.
* Support different way to store times (utc or timezoned).
* Dirty tracking should track changes in hashes.
* Use dirty tracking to do efficient updates.
* Make `includes()` a little more efficient when it comes to eager loading both
  sides of an association.
* Support for read-only fields.
* Support for field aliases and/or custom primary key names.
* Leverage indexes for comparison operators (using `between()`).
* Implement the associated validator.
* Support some form of single embedded documents (some sort of nice wrapper for
  hashes).
* Support for instrumentation such as New Relic.
* Support for popular gems such as Devise.
* Give some progress bars on the indexing, and also countdowns/confirmation before dropping indexes.
* Accept multiple database connections strings for failovers.
* Generic "polymorphic" support for `belongs_to` associations.

## Changelog

### 0.8.0 -- Dec. 31st 2013

* First documented release of NoBrainer.
