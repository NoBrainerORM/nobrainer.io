---
layout: docs
title: Querying
prev_section: associations
next_section: scopes
permalink: /querying/
---

NoBrainer supports a rich query language that supports a wide range of features.
This section is organized in two parts. The first one describes methods used
to construct criteria, and the second one describes the methods that evaluate
criteria.

## Constructing Criteria

### all

`Model.all` yields a criterion that can be chained with other criteria.
This is not so useful as most of the chainable criteria and terminators can be
directly called on the Model class. For example `Model.each { }` and `Model.all.each { }`
are equivalent.

---

### where()

The `where()` method selects documents for which its given predicates are true.
The rules are the following:

* `where(p1,...,pN)` returns the documents that matches all the predicates `p1,...,pN`.

* `where(p1).where(p2)` is equivalent to `where(p1, p2)`

The predicates are described below:

* `[p1,...,pN]` evaluates to `:and => [p1,...,pN]`.
* `:and => [p1,...,pN]`: evaluates to true when all the predicates are true.
* `:or => [p1,...,pN]`: evaluates to true when at least one of the predicates is true.  
Be aware that `[:a => 1, :b => 2]` is the same as `[{:a => 1, :b => 2}]`, which
is not the same as `[{:a => 1}, {:b => 2}]`. NoBrainer prevents the former usage
to avoid programming mistakes. If you knwo what you are doing, you may use `:_or`.
* `:not => p`: evaluates to true when `p` is false.
* `:attr => value` evaluates to `:attr.eq => value`
* `:attr.eq => /regexp/` evaluates to true when `attr` matches the regular expression.
* `:attr.eq => (min..max)` evaluates to true when `attr` is between the range.
* `:attr.eq => value` evaluates to true when `attr` is equal to `value`.
* `:attr.not => value` evaluates to `:attr.ne => value`.
* `:attr.ne => value` evaluates to `:not => {:attr.eq => value}`.
* `:attr.gt => value` evaluates to true when `attr` is greater than `value`.
* `:attr.ge => value` evaluates to true when `attr` is greater than or equal to `value`.
* `:attr.gte => value` evaluates to `:attr.ge => value`
* `:attr.lt => value` evaluates to true when `attr` is less than `value`.
* `:attr.le => value` evaluates to true when `attr` is less than or equal to `value`.
* `:attr.lte => value` evaluates to `:attr.le => value`.
* `:attr.in => [value1,...,valueN]` evaluates to true when `attr` is in the specified array.
* `:attr.nin => values` evaluates to `:not => {:attr.in => values}`.
* `:attr.defined => true` evaluates to true when `attr` is defined.
* `:attr.defined => false` evaluates to true when `attr` is undefined.
* `:attr.near => geo_value` evaluates to true when `attr` is near `geo_value`.
* `:attr.intersects => geo_value` evaluates to true when `attr` intersects `geo_value`.
* `:attr.any => value` evalues to true when any of the `attr` values are equal to `value`.
* `:attr.all => value` evalues to true when all of the `attr` values are equal to `value`.
* `:attr.any.op => value` evalues to true when any of the `attr` values match `value` with `op`.
* `:attr.all.op => value` evalues to true when all of the `attr` values match `value` with `op`.
* `lambda { |doc| rql_expression(doc) }` evaluates the RQL expression.

A couple of notes:

* `:attr.keyword => value` can also be written as `:attr.keyword value`.

* `where()` will try to use one of your declared indexes for performance.
Learn more about indexes in the [Indexes](/docs/indexes) section.
For example, when using the `in` keyword, NoBrainer will use the
[`get_all()`](http://www.rethinkdb.com/api/ruby/#get_all)
command if there is an index declared on `attr`. Otherwise, NoBrainer will
construct a query equivalent to `Model.where(:or => [:attr => value1,...,:attr => valueN])`.
When using comparison operators, NoBrainer leverage the RQL
[`between()`](http://www.rethinkdb.com/api/ruby/#between) command if an index is
available on `attr`.
When using the `any` keyword, NoBrainer tries to use a `multi` index if available.

* `Model.where(:attr => value1).where(:attr => value2)` will match no
documents if `value1 != value2`, even when using a `default_scope`.

* `where()` can also take a block to specify an additional RQL filter.

* `where()` also accept belongs\_to associations. In which case, the foreign key is used.
For example `Comment.where(:post => Post.first)` is valid. `Post.first.comments` is better though.

* Nested hash queries with keywords are not yet supported. Use a RQL filter in this case.

As an example, one can construct such query:

{% highlight ruby %}
Model.where(:or => [->(doc) { doc[:field1] < doc[:field2] },
                    :field3.in ['hello', 'world'])
     .where(:field4 => /ohai/, :field5.any.gt(4))

{% endhighlight %}

---

### order_by()/reverse_order/without_ordering

`order_by()` allows to specify the ordering in which the documents are returned.
Below a couple of examples to show the usage of `order_by()`:

* `order_by(:field1 => :asc, :field2 => :desc)` orders by field1 ascending
  first, and then field2 descending.
  This syntax works because since Ruby 1.9, hashes are ordered.
* `order_by(:field1, :field2)` is equivalent to `order_by(:field1 => :asc, :field2 => :asc)`
* `order_by { |doc| doc[:field1] + doc[:field2] }` sorts by the sum of field1
  and field2 ascending.
* `order_by(->(doc) { doc[:field1] + doc[:field2] } => :desc)` sorts by the sum
  of field1 and field2 descending.
* `criteria.reverse_order` yields criteria with the opposite ordering.
* `criteria.without_ordering` yields criteria with no ordering.
* The latest specified `order_by()` wins. For example,
  `order_by(:field1).order_by(:field2)` is equivalent to `order_by(:field2)`.

NoBrainer always order by ascending primary keys by default.

`order_by()` will try to use one of your declared indexes for performance when
possible. Learn more about indexes in the [Indexes](/docs/indexes) section.

---

### skip()/offset()/limit()

* `criteria.skip(n)` will skip `n` documents.
* `criteria.offset(n)` is an alias for `criteria.skip(n)`.
* `criteria.limit(n)` limits the number of returned documents to `n`.

When compiling the RQL query, the skip/limit directives are applied at the end
of the RQL query, regardless of their position on the criteria.

---

### raw

* `criteria.raw` will no longer output model instances, but attribute hashes as
received from the database.

---

### scoped/unscoped

* `criteria.scoped` will enable the use of the default scope on the model if
defined. This behavior is the default.
* `criteria.unscoped` will disable the default scope.

---

### pluck()/without()/lazy_load()

* `criteria.pluck(fields)` retreives only the specified fields from the
documents.
* `criteria.without(fields)` retreives all but the specified fields from
the documents.
* `criteria.lazy_load(fields)` retreives all but the specified fields from
the documents, but allow lazy fetching.

These methods have an API similar to the RQL one. However, they differ in
different ways:

* Missing attributes from models will not be readable. An error
`NoBrainer::Error::MissingAttribute` will be raised if accessed.
* `lazy_load()` is the same thing as `without()`, except that accessing a
missing attribute does not raise an exception, but provides the attribute value
by running an extra query.
* When using both `pluck()` and `without()` in a query, all `without()`
declarations are ignored, `pluck()` wins.
* The primary key or the `_type` field for polymorphic
classes cannot be removed from the documents, unless you use `.raw` to skip the
model instantiation.
* You can undo a `pluck()` or a `without()` by passing a hash with false values.
For example: `without(:field1, :field2).without(:field1 => false)` is equivalent
to `without(:field2)`.

---

### with_index/without_index/used_index/indexed?

* `criteria.with_index(index_name)` forces the use of index_name during the where() RQL
generation. If the index cannot be used, an exception is raised.
* `criteria.with_index` forces the use of an index to prevent slow queries.
If an index cannot be used, an exception is raised.
* `criteria.without_index` disables the use of indexes.
* `criteria.used_index` shows the index name used if any.
* `criteria.indexed?` returns `true` when an index is in use.

---

### with_cache/without_cache

* `criteria.with_cache` enables the use of the cache.
* `criteria.without_cache` disable the use of the cache.
* `criteria.reload` kills the cache.

Read more about caches in the [Caching](/docs/caching) section.

---

### without_distinct

* `criteria.without_distinct`: When constructing RQL queries operating on multi
  indexes, do not use the [`r.distinct`](http://rethinkdb.com/api/ruby/#distinct)
  operator.

---

### eager_load()

* `criteria.eager_load(:some_association)` eager loads the association. Read more
about eager loading in the [Eager Loading](/docs/eager_loading) section.

---

### after_find()

* `criteria.after_find(->(doc) { puts "Loaded #{doc}" })` runs the specified
  callback whenever a document is instantiated through the criteria.

Multiple callbacks can be passed by calling `after_find` multiple times.
`after_find` accepts lambdas as arguments or blocks.

Calling `reload` on an instance will not trigger these callbacks again.

Note that `Model.after_find().first` declares a callback on the
model class, which triggers the callback on every fetched instances.
Using `Model.all.after_find().first` only triggers the callback for that
specific fetched instance.

The [Callbacks](/docs/callbacks) section describes the order in which the
`after_find` callback is executed.

The `after_find` feature is used internally by the `has_many` association to set the
corresponding reverse `belongs_to` association.

### extend()

* `criteria.extend(module, ...)` extends the current criteria and any chained
criteria with the given modules. Note that a block may also be given to `extend()`.

## Evaluating a Criteria

### count

* `criteria.count` returns the number of documents that matches the criteria.
* `criteria.empty?` is an alias for `count == 0`
* `criteria.any?` is an alias for `count != 0` if no block is given. When a block
  is given, the method call is proxied to `to_a`.

---

### update_all/replace_all/delete_all/destroy_all

* `criteria.update_all` update all documents matching the criteria following the
[`r.update()`](http://www.rethinkdb.com/api/ruby/#update) semantics.
* `criteria.replace_all` replaces all documents matching the criteria following the
[`r.replace()`](http://www.rethinkdb.com/api/ruby/#replace) semantics.
* `criteria.delete_all` deletes all documents matching the criteria following the
[`r.delete()`](http://www.rethinkdb.com/api/ruby/#delete) semantics.
* `criteria.destroy_all` instantiates the models, run the destroy callbacks and
deletes the documents. Returns the array of destroyed instances.

---

### each/to_a

* `criteria.each` enumerates over the documents.
* `criteria.to_a` returns an array of documents matching the criteria.
* `criteria.some_method_of_array` will proxy `some_method_of_array` to `to_a`

---

### first, first!, last, last!, sample

* `criteria.first` returns the first matched document.
* `criteria.last` returns the last matched document.
* `criteria.first!` returns the first matched document, raises if not found.
* `criteria.last!` returns the last matched document, raises if not found.
* `criteria.sample` returns a document picked at random from a uniform distribution.
* `criteria.sample(n)` returns an array of `n` documents picked at random from a uniform distribution.

The bang flavors raise a `NoBrainer::Error::DocumentNotFound` exception if not found
instead of returning `nil`.  If left uncaught in a Rails controller, a 404
status code is returned.

### find()

* `Model.find(id)` is equivalent to `Model.unscoped.where(:id => id).first!`.
* `Model.find?(id)` is equivalent to `Model.unscoped.where(:id => id).first`.

Note that `find()` is only defined on the `Model` class, and not on criteria.

---

### min, max, avg, sum

* `criteria.min(:field)` returns a document which has the minimum value of `field`.
* `criteria.max(:field)` returns a document which has the maximum value of `field`.
* `criteria.avg(:field)` returns the average of `field` values.
* `criteria.sum(:field)` returns the sum of `field` values.

Note that you may also pass a lambda expression instead of a field. For example,
`criteria.min { |doc| doc['field1'] + doc['field2'] }` returns a document
for which `field1 + field2` is minimum

## Manipulating Criteria

You can merge two criteria with `merge()` or `merge!()`:

{% highlight ruby %}
criteria3 = criteria1.merge(criteria2)
criteria1.merge!(criteria2)
{% endhighlight %}

To retrieve the selecting criteria of a model instance, you may use `instance.selector`.
This selector is used internally and is equivalent to `r.table('models').get(instance.id)`.
