---
layout: docs
title: Roadmap
prev_section: multi_tenancy
next_section: changelog
permalink: /roadmap/
---

The roadmap is the following. Items at the beginning of the list are somewhat higher priority.

* Write a bunch of recipes and patterns.
* Provide some `upsert()` primitive.
* Add a way to remove an attribute from a document.
* Support type definitions like `[Integer]`.
* Accept multiple database connections strings for failovers, connection pool.
* Provide 2PC primitives since we don't have transactions.
* Support for instrumentation hooks such as New Relic.
* Support embedded documents. Embedding should be done by using the type system like regular fields.
* Rake tasks should explicitly create database/tables if database/table on demand is turned off.
* Make NoBrainer really fast.
