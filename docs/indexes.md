---
layout: docs
title: Indexes
permalink: /indexes/
---

RethinkDB supports four kinds of secondary indexes:
1. Simple indexes based on the value of a single field.
2. Compound indexes based on multiple fields.
3. Multi indexes based on arrays of values.
4. Indexes based on arbitrary expressions.

NoBrainer provides methods to declare indexes which can then be leveraged when
generating queries as RethinkDB does not use indexes automatically.

## Declaring Indexes

{% highlight ruby %}
class Post
  include NoBrainer::Document

  # Indexes can be declared on belongs_to and fields declarations
  belongs_to :author, :index => true  # Simple index
  field :tags, :index => :multi # Multi index
end

class Author
  include NoBrainer::Document

  field :tags
  field :first_name
  field :last_name
  has_many :posts

  # Indexes can also be declared with the index keyword as such:

  # Simple index
  index :first_name
  index :created_at

  # Multi index
  index :tags, :multi => true

  # Compound index with implicit name
  index [:first_name, :last_name]

  # Compound index with explicit name
  index :full_name_compound, [:first_name, :last_name]

  # Arbitrary index
  index :full_name_lambda, ->(doc){ doc['field1'] + "_" + doc['field2'] }

  # Arbitrary index, multi
  index :field12, ->(doc){ [doc['field1'], doc['field2']] }, :multi => true
end
{% endhighlight %}

## Using Indexes

Because RethinkDB requires explicit index usage, NoBrainer tries to
leverage indexes to compile efficient queries implicitly. For example:

{% highlight ruby %}
# Implicit use of indexes

# Use the index declared on the belongs_to association
author.posts.each { }

# Also use the author_id index with a get_all query
Author.eager_load(:posts).first

# Also use the author_id index with a get_all query
Post.where(:author_id.in => [1,2,3]).each { }

# Uses the created_at index with a between query
Author.where(:created_at.gt => 1.year.ago)

# Use a multi index
Author.where(:tags.any => 'programmer')

# Use the full_name_compound index
Author.where(:first_name => 'John', :last_name => 'Saucisse')

# Explicit use of indexes

# Use the simple index first_name
Author.where(:first_name => 'John')

# Explicit use of the compound index full_name_compound
Author.where(:full_name_compound => ['John', 'Saucisse'])

# Explicit use of the lambda index full_name_lambda
Author.where(:full_name_lambda => 'John_Saucisse')
{% endhighlight %}

Because of the implicit/explicit usage of indexes, NoBrainer does not allow a
compound or arbitrary index to have the same name as a regular field.
Otherwise, the query would be ambiguous: would we be filtering on the field or the index?

`criteria.order_by()` will also try to use an index for efficiency. NoBrainer
will try to use an index only on the first ordering clause.

When compiling a query, NoBrainer may have multiple possibilities to pick which
index to use. When not sure, NoBrainer will pick the first declared index in the model.
You may manually sepecify which index to use by criteria with `with_index(index_name)`.
This forces NoBrainer to use the given index when compiling the query.
An error `NoBrainer::Error::CannotUseIndex` will be raised if the provided index
cannot be used. You may also chain `without_index` to disable the usage of
indexes all together.

You may also use `with_index()` without arguments. In this case, an exception
is raised if NoBrainer cannot find an index to use when compiling the query.

The latest `with_index()` in the query wins.

## Testing Indexes

To test your code and do some profiling, you may use `criteria.used_index` to get the
name of the index that will be used for the query. You may also use
`criteria.where_indexed?` or `criteria.order_by_indexed?`
to test if an index is used. Note that these methods applies the default scope
before returning an answer.

## Creating Indexes

Once declared, indexes need to be created before being usable.

When using Rails, you may use the rake task:

{% highlight bash %}
$ rake nobrainer:sync_schema
{% endhighlight %}

You can also update indexes programmatically:

{% highlight ruby %}
NoBrainer.sync_schema # Synchronize table schema
{% endhighlight %}

NoBrainer maintains a list of index metadata in a table named `nobrainer_index_meta`.
This way, NoBrainer can keep track of the indexes state on the database, and update
indexes which definition have changed.

NoBrainer waits for the index creation by default.
You may pass `:wait => false` to `sync_schema` to skip the wait.

## Aliases

An alias can be specified on a given index as such:

{% highlight ruby %}
index :email, :store_as => :e
{% endhighlight %}

NoBrainer will translate all the references to that index when compiling queries
and reading models back from the database.

The only place you need to be careful is when using RQL, including passing RQL lambda.
NoBrainer does not translate aliases with user provided RQL code.

## External Indexes

If you prefer to manage certain indexes yourself, you may declare them as external as such:

{% highlight ruby %}
index :email, :external => true
{% endhighlight %}

NoBrainer does not touch external indexes when synchronizing indexes.

## Reflection

You may go through the list of declared indexes on a model by looking up the
hash `Model.indexes` of the form `{:index_name => index}`.
`index.kind` is the kind of index which can be `:single`, `:compound`, or `:proc`.
`index.what` is the indexed value which is the field name, field names, or proc depending if the index kind is a single, compound, or proc, respectively.
`index.multi` is a boolean indicating whether the index is a multi index.
`index.geo` is a boolean indicating whether the index is a geo index.
