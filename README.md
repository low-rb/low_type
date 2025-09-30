# LowType

LowType introduces the concept of "type expressions" in method arguments. When an argument's default value resolves to a class instead of an instance then it's treated as a type expression. Now you can have types in Ruby in the simplest syntax possible, only adding them as needed:

```ruby
class MyClass
  include LowType

  def say_hello(greeting: String)
    # Raises exception at runtime if greeting is not a String
  end
end
```

## Default values

Place `|` after the type definition to provide a default value when the argument is `nil`:
```ruby
def say_hello(greeting = String | 'Hello')
  puts greeting
end
```

Or with keyword arguments:
```ruby
def say_hello(greeting: String | 'Hello')
  puts greeting
end
```

If you want to populate the argument from a variable by another name, you can use `||` like usual:

```ruby
def say_hello(greeting = String | @saved_greeting || 'Hello')
  puts greeting
end
```

Or with keyword arguments:
```ruby
def say_hello(greeting: String | @saved_greeting || 'Hello')
  puts greeting
end
```

## Enumerables

Place your class inside square brackets (`[]`) just after an `Array` or `Hash` or any enumerable class like so:
```ruby
def say_hello(greetings: Array[String])
  puts greetings
end
```

The default value for this type would look like:
```ruby
def say_hello(greetings: Array[String] | ['Hello', 'Howdy', 'Hi'])
  puts greetings
end
```

## Return values

Wrap all of your method arguments inside a `Lambda` function to define a return value type:
```ruby
def say_hello((greetings: Array[String]) -> { String })
  puts greetings
  # Raises an exception if the returned value is not a String
end
```

Return values can also be defined as `nil`able:
```ruby
def say_hello((greetings: Array[String]) -> { String | nil })
  puts greetings
end
```

## Technical Considerations

### `[]` Enumerable Syntax

The `[]` class methods for `Array`, `Hash` and other enumerable classes are redefined in the context of type expressions to no longer return an enumerable instance. This 🍰 *syntactic sugar* 🍭 is only for this context. If you want to create an `Array` or `Hash` instance inside a type expression then use `Array.new()` or `Hash.new()` or the Array literal `[]` or Hash literal `{}` syntax.

### `|` Default Value Syntax

The pipe symbol (`|`) is treated as the default value operator (it's technically a method) in the context of type expressions. 
The `Integer` class bitwise operator (`|`) is redefined in the context of type expressions (and only in this context) to use the default value operator. 
If you have custom classes that define a `|` class method and you'd like to use a default value for them in a type expression, then let LowType know:

```ruby
LowType.redefine([:custom_class_name])
```

# Philosophy

Ruby is an amazing language **BECAUSE** it's not typed. I don't believe Ruby should ever be fully typed, this is just a module to include in some areas of your codebase where you'd like a little extra assurance that the right values are coming in/out.
