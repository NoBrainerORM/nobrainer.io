---
layout: docs
title: Validations
prev_section: callbacks
next_section: dirty_tracking
permalink: /validations/
---

## Declaring Validators

Validations works the same way as in ActiveRecord because NoBrainer reuses the
ActiveModel validation logic. If you are not familiar with how validations
typically operate, please read the following documentation:
[ActiveRecord validations](http://edgeguides.rubyonrails.org/active_record_validations.html).  
However, there are a some differences with the
associated validator and the uniqueness validator, which are explained below.

### Associated Validator

The associated validator is not implemented yet.

### Uniqueness Validator

The uniqueness validator accepts a `scope` option, but no `case_sensitive`
option. downcasing the attribute in a `before_save/validation` callback is probably best.

The uniqueness validator is racy (like other ORMs), concurrent requests may both
pass the validation, and both could persist successfully the same supposedly
unique field.
Uniqueness validators are useful in conjunction with a unique secondary index,
but since RethinkDB is sharded, unique secondary indexes would be a performance
problem, and so the RethinkDB team decided to not implement them.
To really ensure uniqueness, you must either:

1. Rely on the default primary key index, which is the only index that can give
   a unique guarantee with RethinkDB. By assigning the `id` of your model with
   the field that is supposed to be unique in question, the database will raise
   an error if you try to use the same id twice.
2. If you cannot use such primary key in your main model, you may create an
   auxiliary table by using a dummy model.
3. Use another system such as Redis or ZooKeeper to perform a distributed lock.

## When are validations performed?

### Validations are performed on:

Validations are performed when calling the following methods on an instance:
* `save`
* `save!`
* `create`
* `create!`
* `update_attributes`
* `update_attributes!`

If you want to bypass validations, you may pass the `:validate => false` option
to these methods, which can be quite handy in a development console. Do not use
such thing in your actual code.

The bang versions follow the same semantics of ActiveRecord which is to raise
when validation fails. NoBrainer raises a `NoBrainer::Error::DocumentInvalid`
exception when validation fails.
The non bang versions populate the errors array attached to the instance.
`save` and `update_attributes` return true or false depending if the validations
failed, while `create` returns the instance with an non empty `errors`
attribute.

### Validations are *not* performed on:

Validations are not performed when calling the following methods on an instance:
* `update`
* `replace`

These methods accept a RQL lambda expression and permit advance usage such as:
`instance.update { |doc| { :field1 => doc[:field1] * 2 } }` which makes it
really hard to perform validations.

Further, validations are not performed when updating all documents matching a
criteria, such as `Model.update_all()`.
