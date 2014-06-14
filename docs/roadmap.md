---
layout: docs
title: Roadmap
prev_section: multi_tenancy
next_section: changelog
permalink: /roadmap/
---

The roadmap is the following. Items at the beginning of the list are somewhat higher priority.

* Support queuable atomic operations.
* Support query keywords in nested documents to allow queries such as:  
  `User.where(:address => { :zipcode.not => 1024 })`.
* Support for field aliases.
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
