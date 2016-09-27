---
layout: docs
title: Introduction
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
* NoBrainer runs on Ruby MRI 2.x.
* NoBrainer does not depend on Rails, but plays nicely with Rails 4 and Rails 5.
* NoBrainer depends on the [`rethinkdb`](https://rubygems.org/gems/rethinkdb),
      [`activemodel`](https://github.com/rails/rails/tree/master/activemodel),
      [`activesupport`](https://github.com/rails/rails/tree/master/activesupport),
      [`middleware`](https://github.com/mitchellh/middleware) gems.
      These dependencies are automatically pulled in when you install the
      `nobrainer` gem.

## Roadmap & Changelog

Latest gem version: **0.33.0 -- Sep. 27, 2016**.

master branch: [![Build Status](https://travis-ci.org/nviennot/nobrainer.svg?branch=master)](https://travis-ci.org/nviennot/nobrainer)

Follow the [Roadmap](/docs/roadmap/) and read the [Changelog](/docs/changelog).

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
further [configuration](/docs/installation) or database migrations.

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
