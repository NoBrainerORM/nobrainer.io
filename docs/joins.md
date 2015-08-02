---
layout: docs
title: Joins
prev_section: scopes
next_section: eager_loading
permalink: /joins/
---

## Performing Inner Table Joins

NoBrainer allows inner table joins on associations with `join()`.

Suppose we have posts and comments:

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

`join()` accepts arrays and hashes to describe the associations to join,
similarly to `eager_load()`.

## Examples

The first example shows a table join on a `belongs_to` association between posts
and authors:

{% highlight ruby %}
Post.join(:author).each do |post|
  author = post.author # access the post's author
end
{% endhighlight %}

`join()` performs an inner join on the provided associations, the query
iterates on posts that have an author.

---

The second example shows two joins on `has_many` associations.

{% highlight ruby %}
Author.join(:posts => :comments).each do |author|
  post = author.posts.first # access the post
  comment = post.comments.first # access the comment
end
{% endhighlight %}

The query provides one entry per author, per post and per comment, generating
lots of objects. To avoid this, use `eager_load()` described in the next
section.
