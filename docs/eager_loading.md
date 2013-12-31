---
layout: docs
title: Eager Loading
prev_section: scopes
next_section: caching
permalink: /eager_loading/
---

## The N+1 Queries issue

NoBrainer allows eager loading of associations with `includes()` to avoid the N+1
queries issue.  Suppose we have posts and comments:

{% highlight ruby %}
class Author
  has_many :posts
end

class Post
  belongs_to :author
  has_many :comments
end

class Comment
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

## Using includes()

We can use `includes` to eager load the models to reduce the number of queries to 3:

{% highlight ruby %}
comments = Comment.includes(:post => :author)
                  .order_by(:created_at => :desc).limit(100)
comments.each do |comment|
  puts comment.post.author
end
{% endhighlight %}

`includes()` accepts arrays and hashes to describe which association to eager load.
For example, to load all the related to the first Author in 5 queries:

{% highlight ruby %}
Author.includes(:posts => [:author, :comments => :post]).first
{% endhighlight %}

Note that the author and posts will be loaded twice, and posts will be loaded twice
because NoBrainer does not realize that the belongs_to associations correspond
to an already loaded has\_many association.
Something more efficient will be implemented in the future.

NoBrainer allows criteria to be specified on how to include these associations.
When specifying criteria, nested includes can be used to further load associations.
For example:

{% highlight ruby %}
Author.includes(:posts => Post.where(:body => /rethinkdb/).includes([
                            :author,
                            :comments => Comment.order_by(:created_at)]).first
{% endhighlight %}

NoBrainer uses `in` queries such as `Model.where(foreign_key.in => [ids])` to retrieve
associations and can leverage secondary indexes.
You may add an `:index => true` option on the `belongs_to` association to improve
read performance (at the cost of write performance).

NoBrainer prefers such queries because RethinkDB outer joins cannot be used with
an index, and also joins often retrieve too much data when instances are shared
across associations.
