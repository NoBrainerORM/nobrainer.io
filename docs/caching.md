---
layout: docs
title: Caching
prev_section: eager_loading
next_section: rql_layer
permalink: /caching/
---

NoBrainer caches data in three places:

1. `belongs_to` associations: Once the target is retrieved, subsequent calls will
return the same instance as before. Even if deleted from the database.
2. `has_many` associations: Once the target criteria is returned, the same
criteria instance will be returned.
3. Criteria instances cache enumerated items. Whenever the list of documents is
retrieved on a criteria, it is remembered, and all subsequent calls to `first`,
`last`, `count`, `to_a`, `each`, will hit the cache instead of the database. However,
the cache is killed when using `reload`, `update_all`, `destroy_all` or
`delete_all` on the criteria instance.

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

If you do not want to use the cache, you can chain `without_cache` in the
criteria. This will ensure to never use the cache. You may chain `with_cache`
to turn it back on. These two modifiers have precedence over the global
setting which can be set with `cache_documents` in the NoBrainer
[configuration](/docs/configuration).

NoBrainer caching logic is simple, and does not provide any other features than
described making it predictable. You may look at the `has_many` example that
shows the caching layer in action in the [associations section](/docs/associations).
