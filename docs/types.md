---
layout: docs
title: Types
permalink: /types/
---

NoBrainer uses a field type mechanism to automatically cast and validates field
values. Using the type mechanism improves the integrity and security of your
application.

## Specifying Field Types

The following example demonstrates how to specify field types:

{% highlight ruby %}
class User
  field :name,         :type => String
  field :biography,    :type => Text
  field :verified,     :type => Boolean
  field :num_friends,  :type => Integer
  field :last_seen_at, :type => Time
  field :status,       :type => Enum, :in => [:pending, :accepted, :rejected]
end
{% endhighlight %}

The following types are currently supported:

* `String`
* `Text`
* `Integer`
* `Float`
* `Boolean`
* `Symbol`
* `Enum`
* `Time`
* `Date`
* `Binary`
* `Array`
* `Set`
* `Hash`
* `Geo::Point`
* `Geo::Circle`
* `Geo::Polygon`
* `Geo::LineString`

## Model Behavior

The behavior is the following:

* The default field type is `Object`, meaning that anything will do and values
  will be delivered to the database as is.
* Declaring a `Boolean` field adds an `attr?` getter for convenience.
* When assigning an attribute to a value, NoBrainer will attempt to cast the given value
  to the correct type in a safe manner if the value does not match the specified type
  as described below. If the casting operation fails, then NoBrainer leaves the
  value as is, meaning that reading the attribute back will return the uncasted
  value. This should be taken in consideration when writing `before_save`
  callbacks since incorrectly typed values may be read.
* When performing validations, NoBrainer will check that attribute values match
  the specified type. If some values do not match their types, validation errors
  will be added to prevent the model to be persisted.
* `belongs_to` foreign key associations are not type checked.
* When data is read back from the database, no type casting is performed.
  For example, when reading back a field from the database with a
  value of `"1"` (a string), the field value read from the model API will always be
  `"1"` and not `1`, even if the field type is declared to be an `Integer`.
  You must perform a database migration to convert all the strings into integers.

Note that the `nil` value is always valid and never casted. If you wish to
prevent this, you may add a `not_null` or `presence` validation.

## Query Behavior

NoBrainer validates and cast values passed in `where()` queries. When a bad value is
used, a `NoBrainer::Error::InvalidType` exception will be raised.  If left
uncaught in a Rails controller, a 400 status code will be returned. For example:

{% highlight ruby %}
class User
  include NoBrainer::Document
  field :num_friends, :type => Integer
end

User.create(:num_friends => 30)
User.where(:num_friends.gt => "10").first # returns the user
User.where(:num_friends.gt => "10xx").first # raises an InvalidType error
{% endhighlight %}

## Types

### String

* Strings with less than 255 characters are accepted. This length limit is
  configurable with `config.max_string_length`.
* Symbols are accepted.

### Text

* Strings are accepted.

### Integer

* Integers are accepted.
* Strings are converted to integers only when the resulting integer can be
  converted back to the original stripped string. For example, `" -4  "`
  and `"+3"` are valid, but `"4f"` or `""` are not.
* Floats are accepted when their values matches exactly an integer.

### Float

* Floats are accepted.
* Integers are accepted.
* Strings are converted to floats only when the resulting integer can be
  converted back to the original stripped string, excluding leading `0`'s.
  Be aware that the current mechanism assume that the decimal separator is
  `"."'`. No localization is performed, meaning that using `","` as a decimal
  separator will not work.

### Boolean

* `true` and `false` are accepted.
* Strings are accepted with the following rules: the lowercase stripped value
  must either be `true`, `yes`, `t`, `1` or `false`, `no`, `f`, `0`.
* `1` and `0` integers are accepted.

### Symbol

* Symbols are accepted.
* Non empty strings are accepted. The cast operation is `value.strip.to_sym`.

### Enum

Enum is similar to the `Symbol` type, except it adds additional methods.

* First, the `:in` option is mandatory when declaring an Enum field to specify
  the possible values.
* Each of the values specified in the `:in` option generates two methods.
For each allowed `value`, a method `value?` returns whether the defined
field is set to `value`; and a method `value!` changes the field to `value`.
Note that `save` must still be invoked to persist the changes to the database.
* These method names can be prefixed or suffixed by specifying a `:prefix` or
`:suffix` option to avoid naming conflicts.

Example:

{% highlight ruby %}
class User
  include NoBrainer::Document
  field :status, :type => Enum, :in => [:pending, :accepted, :rejected],
                                :default => :pending
end
user = User.new
user.pending? # true
user.rejected!
user.pending?  # false
user.rejected? # true
{% endhighlight %}

### Time

* Times are accepted.
* Dates are not accepted.
* Strings in the ISO 8601 combined date and time format are accepted.
  For example `"2007-04-05T14:30Z"` or `"2007-04-05T12:30-02:00"`.

Note that NoBrainer can be configured with `user_timezone` and `db_timezone` to
specify how timezones should be handled. Read more in the
[Installation](/docs/installation) section to learn more.

Read more about `Time` at the bottom of this page.

### Date

* Dates are accepted.
* Times are not accepted.
* Strings in the ISO 8601 date format are accepted. For example `"2007-04-05"`.
* Any other value is ignored, and a validation error is added.

Note that Dates are persisted in the database as UTC times. This is an important
consideration when querying dates due to time millisecond precision.

Read more about `Date` at the bottom of this page.

### Binary

* Binaries are accepted.
* Strings are accepted.

### Array

* Arrays containing any types are accepted.

### Set

* Sets and Arrays containing any types are accepted.

### Hash

* Hashes containing any types are accepted.

### Geo::Point

* Geo::Point are accepted.
* Pairs of floats: `[longitude, latitude]`.
* Hashes `{:longitude => long, :latitude => lat}` or `{:long => long, :lat => lat}`.

### Geo::Circle

* Geo::Circle are accepted.
* Pairs of `[center, radius]` where `center` can coerce to a `Geo::Point` and
  `radius` to a Float.
* Hash `{:center => center, :radius => radius}`.

Additionally, you may pass options as specified in the
[`r.circle`](http://www.rethinkdb.com/api/ruby/circle/) documentation.

### Geo::Polygon

* Geo::Polygon are accepted
* Accepts an array of values coercible to a `Geo::Point`.

### Geo::LineString

* Geo::LineString are accepted
* Accepts an array of values coercible to a `Geo::Point`.

### DateTime

* Use the `Time` type instead. Read more below.

## Custom Types

NoBrainer supports custom types. The following shows an example to define a `Point` type.

{% highlight ruby %}
class Point < Struct.new(:x, :y)
  # This class method imports a user facing values into the model.
  # For example, calling an attribute setter will call this method.
  # If the given value cannot be casted safely, a
  # NoBrainer::Error::InvalidType error must be raised.
  # Otherwise, the method returns the converted value.
  def self.nobrainer_cast_user_to_model(value)
    case value
    when Point then value
    when Hash  then new(value[:x] || value['x'], value[:y] || value['y'])
    else raise NoBrainer::Error::InvalidType
    end
  end

  # This class method translates the given value to a compatible
  # RethinkDB type value.
  # It is used when writing to the database, for example saving a model.
  def self.nobrainer_cast_model_to_db(value)
    {'x' => value.x, 'y' => value.y}
  end

  # This class method translates a value from the database to the proper type.
  # It is used when reading from the database.
  def self.nobrainer_cast_db_to_model(value)
    Point.new(value['x'], value['y'])
  end
end
{% endhighlight %}

## Overriding Default Behavior

If you wish to override some of the default behavior of an existing type, for
example, to cast integers in an unsafe manner, you may use override the
attribute setter. For example:

{% highlight ruby %}
class User
  field :num_friends, :type => Integer

  def num_friends=(value)
    super(value.to_i)
  end
end
{% endhighlight %}

Another way to override a type behavior is to define custom casting behavior
similarly to custom types. For example, to parse all times with
[chronic](https://github.com/mojombo/chronic), the following code will do:

{% highlight ruby %}
class Time
  def self.nobrainer_cast_user_to_model(value)
    value = Chronic.parse(value) rescue value if value.is_a?(String)
    super(value)
  end
end
{% endhighlight %}

Note that calling `super()` is important as it will take care of the timezone
converstion if needed.

You can also subclass the `Time` class, add the casting method, and call it
`ChronicTime`.  The chronic time casting will only be performed if you use the
`ChronicTime` type instead of the `Time` type.

## Date/Time Notes

Regarding date/time types, here is what you need to know:

* The RethinkDB driver only supports `Time` serialization/deserialization at
  this moment. In Ruby 1.9+, there is no longer the need to use the `DateTime` type
  as the `Time` type no longer has restrictive bounds. Nevertheless, the RethinkDB
  database have some limitations and are described
  [in their documentation](http://www.rethinkdb.com/docs/dates-and-times/).
  Essentially, you can start to worry when you start to deal with times which year is
  outside of the range `[1400, 10000]`. See also [this post](https://gist.github.com/coffeemug/6168031).
* Times are serialized by the driver by passing to the database a special hash
  containing `time.to_f` and its timezone. The database takes this value and
  truncates it to get a precision of a millisecond.
* When writing your application tests, you have to keep this loss of precision
  in mind when using `==` on times. Applying `to_i` before comparing times is a
  good workaround to millisecond rounding issues.

## Enum notes

When adding an `Enum` field, values will not added to existing records in the database. You must perform a migration to add the enum value to your existing records. Otherwise, any queries for enum will be imprecise.

---

If this behavior does not match your expectations, please open an issue on
GitHub.
