---
layout: docs
title: 3rd-party Integration
prev_section: multi_tenancy
next_section: communication
permalink: /3rd_party_integration/
---

## Devise

[nobrainer-devise](https://github.com/nviennot/nobrainer-devise) is an adapter
to make [Devise](https://github.com/plataformatec/devise/) work nicely with
NoBrainer.

Include in your Gemfile:

{% highlight ruby %}
gem 'nobrainer-devise'
{% endhighlight %}

Use devise as usual.

If devise does not work, make sure that your `config/initializers/devise.rb` file
contains `require 'devise/orm/nobrainer'`.
