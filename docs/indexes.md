---
layout: docs
title: Indexes
prev_section: rql_layer
next_section: management
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
  # Indexes can be declared on belongs_to and fields declarations
  belongs_to :author, :index => true  # Simple index
  field :tags, :index => :multi # Multi index
end

class Author
  field :tags
  field :first_name
  field :last_name
  has_many :posts

  # Indexes can also be declared with the index keyword as such:

  # Simple index
  index :first_name

  # Multi index
  index :tags, :multi => true

  # Compound index
  index :full_name_compound, [:first_name, :last_name]

  # Arbitrary index
  index :full_name_lambda, ->(doc){ doc['field1'] + "_" + doc['field2'] }
end
{% endhighlight %}

## Using Indexes

Because RethinkDB requires explicit index usage, NoBrainer tries to
leverage indexes to write efficient queries implicitly. For example:

{% highlight ruby %}
# Implicit use of indexes

# Use the index declared on the belongs_to association
author.posts.each { }

# Also use the post_id index.
Author.includes(:posts).first

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


You can chain criteria with `with_index(index_name)` to force NoBrainer to use a
specific index. An error `NoBrainer::Error::CannotUseIndex`
will be raised if the index cannot be used.
You may also chain `without_index` to disable the usage of indexes.

To test your code and do some profiling, you may use `criteria.used_index` to get the
name of the index that will be used for the query. You may also use
`criteria.indexed?` to test if an index will be used. Note that both of these
methods applies the default scope before returning an answer.

`criteria.order_by()` will also try to use an index for efficiency. NoBrainer
will try to use an index only on the first ordering clause and only supports
explicit index usage. Indexes will not be used if `without_index` has been
applied on the criteria, but `order_by` does not interfere with `with_index()`,
`used_index`, and `indexed?`.

## Creating Indexes

Once declared, indexes need to be created before being usable.

When using Rails, you may use the rake task:

{% highlight bash %}
rake db:update_indexes
{% endhighlight %}

You can also update indexes programmatically:

{% highlight ruby %}
NoBrainer.update_indexes # Update indexes on all models
Model.perform_update_indexes # Update indexes on a specific model
{% endhighlight %}

`update_indexes` will drop indexes that are no longer declared. This might be a
bit dangerous, so we want to provide some confirmation measures in the future.
