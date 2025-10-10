# LowType

LowType introduces the concept of "type expressions" in method arguments. When an argument's default value resolves to a class instead of an instance then it's treated as a type expression. Now you can have types in Ruby in the simplest syntax possible, only adding them as needed:

```ruby
class MyClass
  include LowType

  def say_hello(greeting: String)
    # Raises exception at runtime if greeting is not a String.
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
def say_hello(greetings: String[])
  puts greetings
end
```

The default value for this type would look like:
```ruby
def say_hello(greetings: String[] | ['Hello', 'Howdy', 'Hi'])
  puts greetings
end
```

## Return values

After your method's parameters add `-> { MyType }` to define a return value:
```ruby
def say_hello(greetings: String[]) -> { String }
  puts greetings
  # Raises an exception if the returned value is not a String
end
```

Return values can also be defined as `nil`able:
```ruby
def say_hello(greetings: String[]) -> { String | nil }
  puts greetings
end
```

## Syntax

### `[]` Enumerables

The `[]` class method is redefined in the context of type expressions to represent an array of that object type. Luckily in the wild a `[]` class method is usually used rarely for "factory" or "utility" classes that don't overlap with enumerable classes.

### `|` Default Value / Multiple Types

The pipe symbol (`|`) is used in the context of type expressions to support multiple types and the default value:
- Separate multiple allowed types with pipes: `my_variable = TypeOne | TypeTwo`
- The last *value* defined becomes the default value: `my_variable = TypeOne | TypeTwo | nil`

# Philosophy

Ruby is an amazing language **BECAUSE** it's not typed. I don't believe Ruby should ever be fully typed, this is just a module to include in some areas of your codebase where you'd like a little extra assurance that the right values are coming in/out.
