---
layout: docs
title: Eager Loading
prev_section: scopes
next_section: caching
permalink: /eager_loading/
---

## The N+1 Queries issue

NoBrainer allows eager loading of associations with `eager_load()` to avoid the N+1
queries issue.  Suppose we have posts and comments:

{% highlight ruby %}
class Author
  include NoBrainer::Document
  has_many :posts
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
{% endhighlight %}

Suppose that we want to display the list of the most recent comments along with
their post and author. The following will trigger 201 database queries:

{% highlight ruby %}
comments = Comment.order_by(:created_at => :desc).limit(100)
comments.each do |comment|
  puts comment.post.author
end
{% endhighlight %}

## Using eager_load()

We can use `eager_load` to eager load the models to reduce the number of queries to 3:

{% highlight ruby %}
comments = Comment.eager_load(:post => :author)
                  .order_by(:created_at => :desc).limit(100)
comments.each do |comment|
  puts comment.post.author
end
{% endhighlight %}

{% highlight ruby %}
Post.eager_load(:author, :comments).each do |post|
  post.author
  post.comments.each { ... }
end
{% endhighlight %}

`eager_load()` accepts arrays and hashes to describe the associations to eager load.
For example:

{% highlight ruby %}
Model1.eager_load(:model2, :model3 => [:model4, :model5 => :model6])
{% endhighlight %}

NoBrainer allows criteria to be specified on how to include these associations.
When specifying criteria, nested eager_load can be used to further load associations.
For example:

{% highlight ruby %}
Author.eager_load(:posts => Post.where(:body => /rethinkdb/)
                    .eager_load(:comments => Comment.order_by(:created_at)))
{% endhighlight %}

Remember that NoBrainer will use the model default scopes on all associations,
except on the `belongs_to` associations.

NoBrainer uses `in` queries such as `Model.where(foreign_key.in => [ids])` to retrieve
associations and can leverage secondary indexes.
You may add an `:index => true` option on the `belongs_to` association to improve
read performance (at the cost of write performance).

NoBrainer prefers such queries because RethinkDB outer joins cannot be used with
an index, and also joins often retrieve too much data when instances are shared
across associations.
