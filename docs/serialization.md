---
layout: docs
title: Serialization
permalink: /docs/serialization/
---

## ActiveModel Serialization

NoBrainer reuses the ActiveModel serialization logic.
The documentation can be found
[here](http://api.rubyonrails.org/classes/ActiveModel/Serialization.html).
It provides the usual methods `serializable_hash`, `as_json`, `to_json`.

NoBrainer does not include attributes that are not set. An attribute set to
`nil` will be included.

You may set `Model.include_root_in_json = true` to include the class name in the
JSON representation as such:

{% highlight ruby %}
class Model
  include NoBrainer::Document
  self.include_root_in_json = true
end
{% endhighlight %}

## XML

NoBrainer does not support XML by default. If you wish to use `to_xml`,
feel free to `include ActiveModel::Serializers::Xml` in your model.
