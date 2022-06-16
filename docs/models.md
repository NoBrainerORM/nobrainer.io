---
layout: docs
title: Models
permalink: /docs/models/
---

## Model Declaration

To create a model with NoBrainer, simply include the `NoBrainer::Document` mixin
in your class as such:

{% highlight ruby %}
class User
  include NoBrainer::Document
end
{% endhighlight %}

There is no migrations needed to use the model since NoBrainer creates the
required tables for you by default.

The default table name is `class.name.tableize.gsub('/', '__')`.
You may change the table name as described in the
[Multi Tenancy](/docs/multi_tenancy) section.

## Single Table Inheritance

To use polymorphic models with single table inheritance, simply inherit your
classes. Example:

{% highlight ruby %}
class Admin < User
end
{% endhighlight %}

NoBrainer uses a `_type` attribute in the subclass documents to be able to query
and instantiate the proper classes.

Note that when using Rails, you might have to use `require_dependency` to ensure
that all subclasses are loaded. See more in the Rails guide,
[Autoloading and STI](http://guides.rubyonrails.org/autoloading_and_reloading_constants.html#autoloading-and-sti).

## Polymorphic Associations

Starting with version 0.43.0, NoBrainer supports the Ruby On Rails polymorphic
associations which stores the remote model name in a `_type` column and the
remote model ID in a `_id` column so that you can link any models to the
polymorphic association.

{% highlight ruby %}
class Picture
  include NoBrainer::Document

  belongs_to :imageable, polymorphic: true
end
{% endhighlight %}
_This will add a `imageable_type` and `imageable_id` columns to the model and
NoBrainer will store the name and ID when assigning a model instance to that
association._

Here is an example of a models using the polymorphic association from the
`Picture` class :

{% highlight ruby %}
class Employee
  include NoBrainer::Document

  has_many :pictures, as: :imageable
end

class Product
  include NoBrainer::Document

  has_many :pictures, as: :imageable
end
{% endhighlight %}

_You can retrieve the `Employee` or `Product` pictures with `@instance.pictures`
where `@instance` is an instance of the `Employee` or `Product` classes._
_Similarly, you can retrieve the `Picture` owner with `@instance.imageable` where
`@instance` is an instance of a `Picture` document._

Of course, unlike with ActiveRecord, you don't need any migration script in order
to add the new columns (NoBrainer do it for you automatically), but you need to
create the automatically created index on the new fields using
`NoBrainer.sync_indexes` or `rails nobrainer:sync_indexes`.

See the Ruby On Rails documentation [Polymorphic Associations](https://guides.rubyonrails.org/association_basics.html#polymorphic-associations) to see more.

## Reflection

Sometimes it's useful to go through all the models to do something fancy.
The list of models can be retrieved with `NoBrainer::Document.all`.
When using polymorphism, note that subclasses are not returned, only root classes.
