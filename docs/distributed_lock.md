---
layout: docs
title: Distributed Locks
prev_section: atomic_ops
next_section: indexes
permalink: /distributed_locks/
---

## NoBrainer::Lock

NoBrainer provides a distributed lock mechanism. The lock mechanism uses a
separate table `nobrainer_locks` to leverage RethinkDB's primary key uniqueness
property.

The following describes the interface of the lock.

{% highlight ruby %}
class NoBrainer::Lock
  # The key to lock on to. Must be a String. e.g. "users:nico"
  def initialize(key)
  end

  # Acquires the lock. Raises LockUnavailable if the lock couldn't be
  # acquired before timing out.
  # options accepts:
  # - :expire which set the amount of time in seconds the lock expires.
  # - :timeout which set the amount of time in seconds to wait before
  #   giving up on acquiring the lock.
  # The default values are configurable with NoBrainer::Config.lock_options
  # and are set to :expire => 60, :timeout => 10.
  def lock(options={})
  end

  # Attempts to obtain the lock and returns immediately. Returns true if the
  # lock was granted.
  # options accepts:
  # - :expire which set the amount of time in seconds
  #   the lock expires in seconds.
  def try_lock(options={})
  end

  # Releases the previously acquired lock. Raises LostLock if the lock
  # cannot be unlocked due to loosing the lock.
  def unlock
  end

  # Resets the expiration date of the lock. Raises LostLock if the lock
  # cannot be refreshed due to loosing the lock.
  # options accepts:
  # - :expire which set the amount of time in seconds
  #   the lock expires in seconds.
  def refresh(options={})
  end

  # returns the expired locks.
  def self.expired
  end
end
{% endhighlight %}

This mechanism is used internally by the uniqueness validator to prevent races.

## Usage example

{% highlight ruby %}
lock = NoBrainer::Lock.new("users:nico")
lock.lock
# do stuff in the critical region.
lock.unlock
{% endhighlight %}

## Race Free Uniqueness Validations

When working with traditional ORMs, the uniqueness validator is known to be
racy: two concurrent requests may both pass the validation, and both could
persist successfully the same supposedly unique field.
Uniqueness validators are useful in conjunction with unique secondary indexes.
Since RethinkDB is a sharded database, implementing unique
secondary indexes is a performance problem, and so the RethinkDB team rightfully
decided not to implement them. To really ensure uniqueness, one must either
leverage the primary key uniqueness guarantee, or use a distributed lock.

NoBrainer can be configured to use distributed locks to perform non-racy uniqueness
validations. This mechanism is enabled by providing a *`Lock`* class through the
`distributed_lock_class` setting when configuring NoBrainer. The default
behavior is to use `NoBrainer::Lock`.
You may use any lock service, such as Redis or ZooKeeper, by providing a `Lock`
class that complies to the following API:

{% highlight ruby %}
class Lock
  # The initializer must accept a key argument as a String.
  # The key follow the following format:
  #   "nobrainer:database_name:table_name:field_name:field_value"
  # Example: "nobrainer:production:users:username:nico"
  def initialize(key)
  end

  # Acquires a lock on @key. Returns nothing. May raise exceptions.
  def lock
  end

  # Releases the lock on @key. Returns nothing. May raise exceptions.
  def unlock
  end
end
{% endhighlight %}

The locks are acquired after the `before_create/update` callbacks, and before
the `after_create/update` callbacks.
NoBrainer alpha sorts the keys to be acquired to avoid deadlock issues when
performing multiple uniqueness validations on the same document.
