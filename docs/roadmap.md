---
layout: docs
title: Roadmap
prev_section: multi_tenancy
next_section: changelog
permalink: /roadmap/
---

The roadmap is the following. Items at the beginning of the list are somewhat higher priority.

* Provide Geo support.
* Provide some `first_or_create()` primitive.
* Support query keywords in nested documents to allow queries such as:  
  `User.where(:address => { :zipcode.not => 1024 })`.
* Support joins.
* Support type definitions like `[Integer]` or `{String => Integer}`.
* Support for instrumentation hooks such as New Relic.
* Support generic "polymorphic" support for `belongs_to` associations as opposed to STI.
* Support embedded documents. Embedding should be done by using the type system like regular fields.
* Accept multiple database connections strings for failovers, connection pool.
* Rake tasks should explicitly create database/tables if database/table on demand is turned off.
* Make NoBrainer really fast.
