---
layout: docs
title: Types
prev_section: fields
next_section: timestamps
permalink: /types/
---

NoBrainer uses a field type mechanism to automatically cast and validates field
values.

## Specifying Field Types

The following example demonstrates how to specify field types:

{% highlight ruby %}
class User
  field :name,     :type => String
  field :verified, :type => Boolean
  field :age,      :type => Integer
  field :skills,   :type => Array
end
{% endhighlight %}

Any class will be accepted as a type.

## Model Behavior

The behavior is the following:

* The default field type is `Object`, meaning that anything will do and values
  will be delivered to the database as is. Note that the `id` field has no enforced type.
* Declaring a `Boolean` field adds an `attr?` getter for convenience.
* When assigning an attribute to a value, NoBrainer will attempt to cast the given value
  to the correct type in a safe manner if the value does not match the specified type
  as described below. If the casting operation fails, then NoBrainer leaves the
  value as is, meaning that reading the attribute back will return the uncasted
  value. This should be taken in consideration when writing `before_save`
  callbacks since incorrectly typed values may be read.
* When performing validations, NoBrainer will check that attribute values match
  the specified type. If some values do not match their types, validation errors
  will be added to prevent the model to be persisted.
* `belongs_to` foreign key associations are not type checked.

Note that the `nil` value is always valid and never casted. If you wish to
prevent this, you may add a presence validation.

## Query Behavior

NoBrainer validates and cast values passed in `where()` queries. When a bad value is
used, a `NoBrainer::Error::InvalidType` exception will be raised.  If left
uncaught in a Rails controller, a 400 status code will be returned. For example:

{% highlight ruby %}
class User
  include NoBrainer::Document
  field :age, :type => Integer
end

User.create(:age => 30)
User.where(:age => "30").first # returns the user
User.where(:age => "30xx").first # raises an InvalidType error
{% endhighlight %}

## Safe Casting

NoBrainer performs safe casting for the following types:

### String

* Symbols are accepted.
* Any other values will be ignored.

### Integer

* Strings are converted to integers only when the resulting integer can be
  converted back to the original stripped string. For example, `" -4  "`
  and `"+3"` are valid, but `"4f"` or `""` are not.
* Floats are accepted when their values matches exactly an integer.
* Any other values will be ignored.

### Float

* Strings are converted to floats only when the resulting integer can be
  converted back to the original stripped string, excluding leading `0`'s.
  Be aware that the current mechanism assume that the decimal separator is
  `"."'`. No localization is performed, meaning that using `","` as a decimal
  separator will not work.
* Integers are accepted.
* Any other values will be ignored.

### Boolean

* Strings are accepted with the following rules: the lowercase stripped value
  must either be `true`, `yes`, `t`, `1` or `false`, `no`, `f`, `0`.
* `1` and `0` integers are accepted.
* Any other values will be ignored.

### Symbols

* Non empty strings are accepted. The cast operation is `value.strip.to_sym`.
* Any other values will be ignored.

---

If you want to override some of the above behavior, for example, to cast
integers in an unsafe manner, you may use override the attribute setter. For
example:

{% highlight ruby %}
class User
  field :age, :type => Integer

  def age=(value)
    super(value.to_i)
  end
end

{% endhighlight %}

---

Other types are directly passed to the database driver.

Regarding date/time types, here is what you need to know:

* The RethinkDB driver only supports `Time` serialization/deserialization.
  Note that in Ruby 1.9+, there is no longer the need to use the `DateTime` type
  as the `Time` type no longer has restrictive bounds.
* Times are serialized by the driver by passing to the database a special hash
  containing `time.to_f` and its timezone. The database takes this value and
  truncates it to get a precision of a millisecond.
* Due to the loss of precision, it seems a bit scary to use `Times` to represent
  `Dates` because the floating point precision is insufficient to prevent
  jumps over days when working really far from 1970. We'll address this issue in the future.
* When writing your application tests, you have to keep this loss of precision
  in mind when using `==` on times. Applying `to_i` before comparing times is a
  good workaround.

---

If this behavior does not match your expectations, please open an issue on
GitHub.
