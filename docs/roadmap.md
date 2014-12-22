---
layout: docs
title: Roadmap
prev_section: multi_tenancy
next_section: changelog
permalink: /roadmap/
---

The roadmap is the following. Items at the beginning of the list are somewhat higher priority.

* Drop criteria cache when it has too many elements (like 10,000, it should be configurable) to avoid out of memory issues.
* Raise an error when passing regular controller params, as opposed to strong params.
* Add an `eager_load` alias for `preload()`.
* Write a bunch of recipes and patterns.
* Add an atomic operator to remove an attribute
* Provide some `first_or_create()` primitive.
* Support type definitions like `[Integer]`.
* Accept multiple database connections strings for failovers, connection pool.
* Provide 2PC primitives since we don't have transactions.
* Support query keywords in nested documents to allow queries such as:  
  `User.where(:address => { :zipcode.not => 1024 })`.
* Support for instrumentation hooks such as New Relic.
* Support generic "polymorphic" support for `belongs_to` associations as opposed to STI.
* Support embedded documents. Embedding should be done by using the type system like regular fields.
* Support joins.
* Rake tasks should explicitly create database/tables if database/table on demand is turned off.
* Make NoBrainer really fast.
