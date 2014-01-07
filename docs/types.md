---
layout: docs
title: Field Types
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

## Behavior

The behavior is the following:

* The default field type is `Object`, meaning that anything will do and values
  will be delivered to the database as is. Note that the `id` field has no enforced type.
* When assigning an attribute to a _value_, NoBrainer will attempt to cast the given value
  to the correct type in a safe manner if the value does not match the specified type
  as described below. If the casting operation fails, then NoBrainer leaves the
  value as is, meaning that reading the attribute back will return the uncasted
  value. This should be taken in consideration when writing `before_save`
  callbacks since incorrectly typed values may be read.
* When performing validations, NoBrainer will check that attribute values match
  the specified type. If some values do not match their types, validation errors
  will be added to prevent the model to be persisted.

Note that the `nil` value is always valid and never casted. If you wish to
prevent this, you may add a presence validation.

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

If this behavior does not match your expectations, please open an issue on
Github.
