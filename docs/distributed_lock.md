---
layout: docs
title: Distributed Locks
permalink: /docs/distributed_locks/
---

NoBrainer provides a distributed lock mechanism. The lock mechanism uses a
separate table `nobrainer_locks` to store its locks.
The distributed lock mechanism is used internally by the uniqueness validator
to prevent races.

## Usage example

The following example shows how to execute a piece of code with a distributed
lock held:

{% highlight ruby %}
NoBrainer::Lock.new("jobs:generate_sitemap").synchronize do
  # critical region
end
{% endhighlight %}

## NoBrainer::Lock Interface

The following describes the interface of the lock.

{% highlight ruby %}
class NoBrainer::Lock
  # The key to lock on to. Must be a String. e.g. "users:#{user.id}"
  def initialize(key)
  end

  # Runs the passed block with the lock held. Raises LockUnavailable if
  # the lock cannot be acquired before timing out.
  # options accepts:
  # - :expire which set the amount of time in seconds the lock expires.
  # - :timeout which set the amount of time in seconds to wait before
  #   giving up on acquiring the lock.
  # The default values are configurable with NoBrainer::Config.lock_options
  # and are set to :expire => 60, :timeout => 10.
  def synchronize(options={}, &block)
  end

  # Acquires the lock. Raises LockUnavailable if the lock couldn't be
  # acquired before timing out.
  # options accepts:
  # - :expire which set the amount of time in seconds the lock expires.
  # - :timeout which set the amount of time in seconds to wait before
  #   giving up on acquiring the lock.
  def lock(options={})
  end

  # Attempts to obtain the lock and returns immediately. Returns true if the
  # lock was granted, false otherwise.
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
