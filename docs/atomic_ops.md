---
layout: docs
title: Atomic Operations
permalink: /atomic_ops/
---

NoBrainer supports atomic operations on document attributes to avoid races
during updates (e.g. incrementing a number).
NoBrainer provides a natural Ruby syntax to describe atomic
operations: assignments ran within a `queue_atomic` block are performed
atomically during the next `save()` operation.

## Examples

The following examples use the following base code:

{% highlight ruby %}
class User
  field :num_friends, :type => Integer
  field :friend_ids,  :type => Array
  field :tags,        :type => Set

  field :field1
  field :field2
end

user = User.first
{% endhighlight %}

### Incrementing a field

{% highlight ruby %}
user.queue_atomic do
  user.num_friends += 1
end
user.save!
{% endhighlight %}

### Removing items from an array

{% highlight ruby %}
user.queue_atomic do
  user.friend_ids -= ["id1", "id2"]
end
user.save!
{% endhighlight %}

### Adding items to a set

{% highlight ruby %}
user.queue_atomic do
  user.tags << "red"
end
user.save!
{% endhighlight %}

### Swapping two fields

{% highlight ruby %}
user.queue_atomic do
  user.field1, user.field2 = user.field2, user.field1
end
user.save!
{% endhighlight %}

### Using different fields to compute some value

{% highlight ruby %}
user.queue_atomic do
  user.field2 = (user.num_friends + user.field1)*2
end
user.save!
{% endhighlight %}

### Removing a field

{% highlight ruby %}
user.queue_atomic do
  user.unset(:field1)
end
user.save!
{% endhighlight %}

### Using a RQL value

{% highlight ruby %}
user.queue_atomic do |r|
  user.field1 = r.expr(1+2)
end
user.save!
{% endhighlight %}

## Operations

* Atomic operations are performed when invoking `save()`.
* Multiple atomic operations can be queued.
* Once an attribute has atomic operations queued, validations are no longer
  performed on that attribute.
* Once an atomic value is queued, the attribute value cannot be read anymore.

The following describes operations that can be performed on various types:

### Any types

* `instance.unset(:field)` removes the specified field from the document.
* `instance.field = value` assigns `field` to `value`, which can be a
  RQL expression, or some operation using other fields from the same document.

### Array

* `values1 & values2` performs the set intersection between `values1` and `values2`.
* `values1 | values2` performs the set union of `values1` and `values2`.
* `values1 + values2` performs the concatenation of `values1` and `values2`.
* `values1 - values2` performs the difference between `values1` and `values2`.
* `values << value` appends `value` to `values`.
* `values.delete(value)` removes `value` from `values`.

### Set

Same as `Array`, except all operations are done with `Set` semantics.

### String

* `value1 + value2` performs the concatenation of the two strings.

### Integer / Float

* `+ - / %` performs the usual numeric computations.
