---
layout: docs
title: Fields
prev_section: models
next_section: types
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

`field` accepts the following options:

* `:index` to specify an index.
* `:default` to specify a default value.
* `:type` to enforce a type.
* `:validates` to specify validations.
* `:required` as a shorthand for the presence validation.
* `:unique` as a shorthand for the uniqueness validation.
* `:in` as a shorthand for the inclusion validation.
* `:readonly` to specify if a field cannot be updated.
* `:primary_key` to specify a custom primary key.
* `:as` to specify an alias in the database.
* `:lazy_fetch` to specify whether this field should be fetched on demand.

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

Methods lower in the list calls the method directly above it.
For example, `self[attr]` calls `read_attribute(attr)` which calls `self.attr`.

Note that there is no `attr_protected` method to control mass assignments.
Sanitize your attributes the Rails4 way with
[strong parameters](https://github.com/rails/strong_parameters).

## Overriding attributes

If you wish to override an attribute getter or setter, you may define
the `attr` and `attr=` methods in your class. `super` can be used as usual.
The following shows an example that uses `super` in the setter:

{% highlight ruby %}
class User
  include NoBrainer::Document

  field :email

  def email=(value)
    super(value.strip.downcase)
  end
end
{% endhighlight %}

Note that the setters are _not_ used when reading a document from the database.
Keep this in mind when your database does not match your schema.

## Default Values

To assign a default value to a field, you may pass a `default` option.
You can pass a value or a lambda. The latter will be evaluated at the time of
the assignment.

{% highlight ruby %}
field :num_friends, :default => 0
field :created_at,  :default => ->{ Time.now }
{% endhighlight %}

Defaults values are assigned whenever a model is instantiated in memory, which
happens when `Model.new` is called. Reading a model from the database
calls `Model.new` and therefore performs default value assignments.

A default value is only assigned when the corresponding attribute has not been
set. For example, calling `Model.create(:created_at => nil)` will not trigger
the default value assignment on `created_at`. Please create a GitHub issue
if this behavior is a problem for you.

## Readonly Fields

When declaring a field with `:readonly => true`, the field cannot be reassigned
once persisted to the database.

## Primary Key

NoBrainer allows custom primary keys with the `:primary_key => true` option.
The default primary key is `id` and is declared with:

{% highlight ruby %}
field :id, :type => String, :default => ->{ NoBrainer::Document::Id.generate }
{% endhighlight %}

`NoBrainer::Document::Id.generate` returns ids following the
[BSON ID (MongoDB)](http://docs.mongodb.org/manual/reference/object-id/) format.
This is interesting compared to UUIDs because BSON IDs are somewhat
monotonically increasing with time. NoBrainer always sort by primary key by
default to give predicable and repeatable results. For example, `Model.last`
yields the latest created model, which can be quite handy in development mode.

When comparing two models with `==` or `eql?`, only the primary keys are
compared, not the other attributes.

Specifying a custom primary key changes the default foreign key names in
belongs\_to associations.

## Dynamic Attributes

Dynamic attributes are supported by NoBrainer, but are not enabled by default.
You must include the `NoBrainer::Document::DynamicAttributes` mixin in your model.

By doing so, you will be able to read/write arbitrary attributes to your model with
`read_attribute()`/ `[]` and `write_attribute()`/`[]=`.

## Types

Field types can be declared as such:

{% highlight ruby %}
field :email, :type => String
{% endhighlight %}

Read the [Types](/docs/types) section to learn more.

## Validations

Validations can be declared directly on the field declaration:

{% highlight ruby %}
field :email, :validates => { :format => { :with => /@/ } }
{% endhighlight %}

Read the [Validations](/docs/validations) section to learn more.

## Indexes

A index can be declared on a field as such:

{% highlight ruby %}
field :email, :index => true
{% endhighlight %}

Read the [indexes](/docs/indexes) section to learn more.

## Aliases

An alias can be specified on a given field as such:

{% highlight ruby %}
field :email, :as => :e
{% endhighlight %}

NoBrainer will translate all the references to that field when compiling queries
and reading models back from the database.

The only place you need to be careful is when using RQL, including passing RQL lambda.
NoBrainer does not translate aliases with user provided RQL code.

A simple index declared on an aliased field carries the name of alias in the database,
unless specified otherwise by an `:as` option on the index.

## Lazy Fetching

Some fields can have large content size, for example binary fields.
It might be undesirable to fetch them all the time.
NoBrainer can fetch certain fields on demand by declaring a field to be lazy
fetched. For example:

{% highlight ruby %}
class User
  field :email,  :type => String
  field :avatar, :type => Binary, :lazy_fetch => true
end

user = User.first
user.email  # In memory access.
user.avatar # Performs an extra query to fetch the data.
{% endhighlight %}

## Reflection

You can access the field definitions with `Model.fields`.  
It returns a hash of the form `{:field_name => options}`.

You can undefine a previously defined field with
`Model.remove_field(field_name)`. This feature is needed when removing the
default primary key `id` for example.

You may access the name of the current primary key with `Model.pk_name`.
You may access the primary key value of a document with `instance.pk_value`.
