---
layout: docs
title: Serialization
prev_section: timestamps
next_section: persistence
permalink: /serialization/
---

## ActiveModel Serialization

NoBrainer reuses the ActiveModel serialization logic for JSON and XML.
The documentation can be found
[here](http://api.rubyonrails.org/classes/ActiveModel/Serialization.html).
It provides the usual methods `serialiable_hash`, `as_json`, `to_json`, `to_xml`.

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
