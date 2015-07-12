---
layout: docs
title: Associations
prev_section: dirty_tracking
next_section: querying
permalink: /associations/
---

## Associations

NoBrainer supports `belongs_to` and `has_many` associations.

NoBrainer is different from other ORMs: `has_many` associations are not writable
because writable `has_many` associations are leaky abstractions and provide hard to
understand semantics. Therefore there is no `has_and_belongs_to` associations.

Remember that NoBrainer never saves a model instance under the covers.

In this section, the owner refers to the model where the association is declared,
and the target refers to the other side of the association.

## belongs\_to Association

The `belongs_to` syntax is the following: `belongs_to :target, options`

The following describes the different options `belongs_to` accepts:
* `:primary_key`: the primary key to use on the target. Defaults to `:id`.
* `:foreign_key`: the foreign key to use. Defaults to `#{target_name}_#{primary_key}`.
* `:foreign_key_as`: the alias for the foreign key. Defaults to `nil`.
* `:class_name`: the target class name. Defaults to `Target`.
* `:index`: when true, the foreign key field gets an index declared to speed to
  the corresponding `has_many` association. Defaults to `nil`.
* `:validates`: passes a validation to `target`, and not `target_id`. Useful
  to provide a presence validation.
* `:required`: a shorthand for `:validates => { :presence => true }`.

The following describes the behavior of `belongs_to` associations:

* `owner.target` looks up the target instance by performing
  `Target.find(owner.foreign_key)`. The result is cached regardless if the target is found or not.
* `owner.target=(value)` sets `owner.foreign_key = value.primary_key`, and caches the value.
* `owner.foreign_key=(value)` sets the foreign key and kills the target cache.

NoBrainer will always insert an `after_validation` callback to check that if there
is a target set, then it must be `persisted?`. If the target is not persisted,
NoBrainer will raise a `NoBrainer::Error::AssociationNotPersisted` exception.

You can read more about how presence validations are handled on belongs\_to
associations in the [validations section](/docs/validations#presence_validations_on_belongs_to_associations).

## has\_many Association

The `has_many` syntax is the following: `has_many :targets, options`

The following describes the different options `has_many` accepts:
* `:primary_key`: the primary key to use. Defaults to the owner's primary key.
* `:foreign_key`: the foreign key that the targets use. Defaults to `#{owner_name}_#{primary_key}`.
* `:class_name`: the targets class name. Defaults to `Target`.
* `:dependent`: configure the destroy behavior further explained below. Defaults
  to `nil`.
* `:through`: See the `has_many through` association below.
* `:scope`: A lambda that evaluates to a criteria which gets applied to the query.
  This lambda is evaluated in the context of the `Target` class, which means
  that using named scoped defined on `Target` is possible.

The dependent option tells what to do when destroying an owner that has many
targets with a `before_destroy` callback. The different dependent values are:
* `nil`: do nothing
* `:destroy`: `destroy_all` the targets.
* `:delete`: `delete_all` the targets.
* `:nullify`: `update_all` the targets' foreign keys to `nil`.
* `:restrict`: raises a `NoBrainer::Error::ChildrenExist` if a target still exists.

When performing the dependent destroy logic, the targets criteria is run
`unscoped` (without the any declared `default_scope`).

The following describes the behavior of `has_many` associations:

* The `has_many` association is read only. NoBrainer makes no attempts
  whatsoever in collecting targets as they get created with `Target.create()`.
  This also mean that you cannot use `post.comments.build`. Rather, you should use
  `Comment.create(:post => post)` and have a presence validation on post.

* Loading targets through `instance.targets` will automatically set their
  matching `belongs_to` associations to `instance`, with or without eager
  loading.

* `instance.targets` returns the criteria `Target.where(foreign_key => owner.primary_key)`,
  which is cached. This means that you will always get the same instance of
  criteria on a given instance, which will cache enumerated documents.
  When a custom `:scope` is defined, the custom scope is evaluated in the
  context of `Target` and added to the criteria. Note that using `unscoped` has
  no effect on the custom scope.

`has_many` associations leverage the cache, illustrated with the following
example. You can read more about the caching behavior in the [caching
section](/docs/caching).

{% highlight ruby %}
class Post
  include NoBrainer::Document
  has_many :comments
end

class Comment
  include NoBrainer::Document
  belongs_to :post
end

post = Post.create
post.comments.to_a # returns []
Comment.create(:post => post)
post.comments.to_a # still returns [], because the enumerator has already
                   # been invoked, and thus the comments are cached.
post.comments.reload
post.comments.to_a # contains a comment.
{% endhighlight %}

## has\_many through Association

The `has_many` syntax is the following: `has_many :targets, :through => :association`.
`targets` must be a defined association on the through `association`. You may
go through any associations. No other options are supported.

The implementation of `has_many` through is essentially a thin wrapper around the
eager loading functionality, which implies that reading a `has_many` through
association will not yield a criteria, but a plain unmodifiable array which gets cached.

The following show an example of using a `has_many` through association:

{% highlight ruby %}
class Author
  include NoBrainer::Document
  has_many :posts
  has_many :comments, :through => :posts
end

class Post
  include NoBrainer::Document
  belongs_to :author
  has_many :comments
end

class Comment
  include NoBrainer::Document
  belongs_to :post
end

author = Author.create
post = Post.create(:author => author)
2.times { Comment.create(:post => post) }
author.comments # returns the two comments
{% endhighlight %}

## has\_and\_belongs\_to\_many Association

NoBrainer will never support such association. Nevertheless, you may create your
own join table as such:

{% highlight ruby %}
class Patient
  include NoBrainer::Document
  has_many :appointments
  has_many :physicians, :through => :appointments
end

class Appointment
  include NoBrainer::Document
  belongs_to :patient
  belongs_to :physician
end

class Physician
  include NoBrainer::Document
  has_many :appointments
  has_many :patients, :through => :appointments
end
{% endhighlight %}

## has\_one Association

The `has_one` association is a `has_many` with the following differences:

* The target name is assumed to be singular instead of plural.
* Reading the target of a `has_one` association returns a single document,
  unlike a `has_many` which returns an array of documents.
  Nevertheless, NoBrainer will emit warnings if your association has more than
  one element.

Note that the `dependent` option behaves like the `has_many`
association one. In other words, all the targets matching the foreign key of the
owner will be subject to the `destroy` behavior, not just the first one.

The `has_one through` association follow the same rules as the `has_many through`
association.

## accept_nested_attributes_for

This will never be implemented since `has_many` associations are read only. This
sort of feature belongs in a separate gem anyway because it's a crazy feature.

## Reflection

You can retrieve the association declarations with `Model.association_metadata`.
It returns a hash of the form `{target_name => metadata_instance}`.
Association instances can be retrieved on a model instance with
`model_instance.associations[metadata_instance]`.
