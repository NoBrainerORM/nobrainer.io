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
* `:foreign_key`: the foreign key to use. Defaults to `:target_id`.
* `:class_name`: the target class name. Defaults to `Target`.
* `:index`: when true, the foreign key field gets an index declared to speed to
  the corresponding `has_many` association. Defaults to `nil`.

The following describes the behavior of `belongs_to` associations:

* `owner.target` looks up the target instance by performing
  `Target.find(owner.target_id)`. When the target is found, the result is cached.
* `owner.target=(value)` sets `owner.target_id = value.id`, and cache the value.
* `owner.target_id=(value)` sets the foreign key and kills the cache.

NoBrainer will always insert an `after_validation` callback to check that if there
is a target set, then it must be `persisted?`. If the target is not persisted,
NoBrainer will raise a `NoBrainer::Error::AssociationNotSaved` exception.

## has\_many Association

The `has_many` syntax is the following: `has_many :targets, options`

The following describes the different options `has_many` accepts:
* `:foreign_key`: the foreign key that the targets use. Defaults to `owner_id`.
* `:class_name`: the targets class name. Defaults to `Target`.
* `:dependent`: configure the destroy behavior further explained below. Defaults
  to `nil`.

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

* `instance.targets` returns the criteria `Target.where(foreign_key => owner.id)`,
  which is cached. This means that you will always get the same instance of
  criteria on a given instance, which will cache enumerated documents.

The presence the cache has some significant implications, illustrated with the
following example. You can read more about the caching behavior in the [caching
section](/docs/caching).

{% highlight ruby %}
class Post
  has_many :comments
end

class Comment
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

---

The `belongs_to` and `has_many` associations have no knowledge of each other.
This can be implement in the future (with an `inverse_of` option) to optimize certain
queries (esp. with eager loading).

`has_many through` association is not implemented yet. However, this feature is
high priority.

## has\_and\_belongs\_to\_many Association

NoBrainer will never support such association. Nevertheless, you may create your
own join table as such:

{% highlight ruby %}
class Patient
  has_many :appointments
  has_many :physicians, :through => :appointments # Not yet implemented
end

class Appointment
  belongs_to :patient
  belongs_to :physician
end

class Physician
  has_many :appointments
  has_many :patients, :through => :appointments # Not yet implemented
end
{% endhighlight %}

## has\_one Association

The `has_one` association is not implemented yet.

## accept_nested_attributes_for

This will never be implemented since `has_many` associations are read only. This
sort of features belongs in a separate gem anyway because it's a crazy feature.

## Reflection

You can retrieve the association declarations with `Model.association_metadata`.
It returns a hash of the form `{target_name => metadata_instance}`.
Association instances can be retrieved on a model instance with
`model_instance.association(metadata_instance)`.
