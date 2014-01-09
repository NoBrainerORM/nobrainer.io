---
layout: docs
title: Caching
prev_section: eager_loading
next_section: rql_layer
permalink: /caching/
---

NoBrainer caches data in three places:

1. Criteria instances cache enumerated items. Whenever the list of documents is
   retrieved on a criteria, it is remembered, and all subsequent calls to `first`,
   `last`, `count`, `to_a`, `each`, will hit the cache instead of the database. However,
   the cache is killed when using `reload`, `update_all`, `destroy_all` or
   `delete_all` on the criteria instance.
2. Associations are cached. Once the target of the association is retrieved, subsequent
   calls will return the same documents without hitting the database again. Note
   that a `has_many` association behaves like a criteria, and thus the rule #1
   applies.
3. Eager loading associations will prepopulate the corresponding association caches.

These are the only places where NoBrainer will cache documents. NoBrainer does
not use an [identity map](http://www.martinfowler.com/eaaCatalog/identityMap.html).

Let's see an example:

{% highlight ruby %}
criteria = Model.all # New criteria instance.
criteria.first       # Calls the database.
criteria.first       # Calls the database again.
criteria.each { }    # We are enumerating.
criteria.first       # Does not call the database.
Model.all.first      # Calls the database, this is a new criteria instance.
Model.delete_all     # Everything is gone.
criteria.first       # Does not call the database, and returns the
                     # same document as before.
criteria.reload      # Just kills the cache, does not perform a database query.
criteria.first       # Calls the database and returns nothing.
criteria.first       # Calls the database again and returns nothing.
{% endhighlight %}

Chaining a criteria always returns a new instance. For example
`criteria.limit(10000)` will return a new criteria instance with an empty cache.
Nevertheless, chaining `preload()` will carry the cache over when present,
and will eager load missing documents on top of the existing caches.

If you do not want to use the cache, you can chain `without_cache` in the
criteria. This will ensure to never use the cache on that criteria. You may
chain `with_cache` to turn it back on.

An important consideration to keep in mind is to turn off caching when iterating
very large tables as each document would get stashed in the cache.  Your program
will start consuming all the memory and die. Example:

{% highlight ruby %}
1_000_000_000.times { Model.create }
Model.each { ... } # bad
Model.without_cache.each { ... } # better
{% endhighlight %}

NoBrainer caching logic is simple, and does not provide any other features than
described making it predictable. You may look at the `has_many` example that
shows the caching layer in action in the [Associations](/docs/associations)
section.
