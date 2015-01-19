---
layout: docs
title: Caching
prev_section: eager_loading
next_section: rql_layer
permalink: /caching/
---

NoBrainer caches data in three places:

1. Criteria instances only cache data when enumerating items. Whenever a *list* of documents is
   retrieved on a criteria (e.g. `each` or `map`), the list is stored in the criteria's cache, and all
   subsequent calls to `first`, `last`, `count`, `to_a`, `each` hit the
   cache instead of the database.
   However, the cache is killed when using `reload`, `update_all`, `destroy_all`
   or `delete_all` on the criteria instance.
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
criteria.reload      # Kills the cache, does not perform a database query.
criteria.first       # Calls the database and returns nothing.
criteria.first       # Calls the database again and returns nothing.
{% endhighlight %}

Chaining a criteria always returns a new instance. For example
`criteria.limit(10000)` will return a new criteria instance with an empty cache.
Nevertheless, chaining `eager_load()` will carry the cache over when present,
and will eager load missing documents on top of the existing caches.

Calling `first` or `count` repeatedly on the same criteria without having
enumerated items beforehand will always trigger a database call.

If you do not want to use the cache, you can chain `without_cache` in the
criteria. This will ensure to never use the cache on that criteria. You may
chain `with_cache` to turn it back on.

When iterating a criteria, its cache can be automatically turned off when it
grows too big, which may happen when iterating very large tables.
When a cache reaches 10,000 elements (configurable with
`config.criteria_cache_max_entries`), the cache is flushed and disabled to
prevent out of memory issues.
