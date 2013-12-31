---
layout: docs
title: Fields
prev_section: models
next_section: timestamps
permalink: /fields/
---

## Field Declaration

With NoBrainer, persisted model attributes are called fields or attributes
interchangeably in the documentation.
Declaring a field is done by using the `field` method.
For example, the following defines a `User` model with a first and last name:

{% highlight ruby %}
class User
  include NoBrainer::Document

  field :first_name
  field :last_name
end
{% endhighlight %}

## Accessing Fields

Defined fields can be accessed with the following methods:

Reading an attribute `attr`:

* `self.attr`
* `self.read_attribute(attr)`
* `self[attr]`

Writing an attribute `attr`:

* `self.attr = value`
* `self.write_attribute(attr, value)`
* `self[attr] = value`

Reading all attributes:

* `self.attributes`

Mass assignment:

* `self.assign_attributes(attrs_hash)`
* `self.attributes = attrs_hash`

Note that methods lower in the list calls the method directly above it.
For example, `self[attr]` calls `read_attribute(attr)` which calls `self.attr`.

If you wish to override an attribute getter or setter, you may define
the `attr` and `attr=` methods in your class. `super` can be used as usual.

Note that there is no `attr_protected` method to control mass assignments.
Sanitize your attributes the Rails4 way with
[strong parameters](https://github.com/rails/strong_parameters).

## Default Values

To assign a default value to a field, you may pass a `default` option.
You can pass a value or a lambda. The latter will be evaluated at the time of
the assignment.

{% highlight ruby %}
field :num_friends, :default => 0
field :created_at,  :default => ->{ Time.now }
{% endhighlight %}

Defaults values are assigned whenever a model is instantiated in memory, which
happens when `Model.new` is called. Note that reading a model from the database
calls `Model.new`.

A default value is only assigned when the corresponding attribute has not been
set. For example, calling `Model.create(:created_at => nil)` will not trigger
the default value assignment on `created_at`. Please create a Github issue
if this behavior is a problem for you.

## Field Types

NoBrainer does not support explicit field types yet. NoBrainer assumes that you are
passing the right value types and will forward them straight to RethinkDB.
This can be a security concern for your application as RethinkDB will accept
hashes and array as field values.
The use of [strong parameters](https://github.com/rails/strong_parameters)
mitigates this issue though.

## Primary Key

NoBrainer does not allow you to change the primary key for the moment, and will
assume `id` to be the primary key. This field is already declared with:

{% highlight ruby %}
field :id, :default => ->{ NoBrainer::Document::Id.generate }
{% endhighlight %}

NoBrainer generates ids following the
[BSON ID (MongoDB)](http://docs.mongodb.org/manual/reference/object-id/) format.
This is interesting compared to UUIDs because BSON IDs are somewhat
monotonically increasing with time. NoBrainer always sort by id by default to
give predicable and repeatable results. For example, `Model.last` yields the
latest created model, which can be quite handy in development mode.

NoBrainer does not have read only fields yet, and thus does not prevent you from
changing the id of a persisted document. Please don't do it.  Sanitize your
arguments when doing mass assignments with strong parameters.

When comparing two models with `==` or `eql?`, only the primary keys are
compared, not the other attributes.

## Dynamic Attributes

Dynamic attributes are supported by NoBrainer, but are not enabled by default.
You must include the `NoBrainer::Document::DynamicAttributes` mixin in your model.

By doing so, you will be able to read/write arbitrary attributes to your model with
`read_attribute()`/ `[]` and `write_attribute()`/`[]=`.

## Indexes

A index can be declared on a field as such:

{% highlight ruby %}
field :email, :index => true
{% endhighlight %}

Read the [indexes section](/docs/indexes) to learn more.

## Reflection

You can access the field definitions with `Model.fields`. It returns
a hash of the form `{:field_name => options}`.

Note that you can undefine a previously defined field with
`Model.remove_field(field_name)`.
