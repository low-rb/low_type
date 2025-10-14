# LowType

LowType introduces the concept of "type expressions" in method arguments. When an argument's default value resolves to a type instead of a value then it's treated as a type expression. Now you can have types in Ruby in the simplest syntax possible, only adding them as needed:

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

If you want to populate the argument from a variable by another name:
```ruby
def say_hello(greeting: String | @saved_greeting)
  puts greeting
end
```

Don't forget that these are just Ruby expressions and you can do more conditional logic as long as the last expression evaluates to a value:
```ruby
def say_hello(greeting: String | (@saved_greeting || 'Hello'))
  puts greeting
end
```

## Enumerables

Wrap your type in an `Array[T]` or `Hash[T]` enumerable type. An `Array` of `String`s looks like:
```ruby
def say_hello(greetings: Array[String])
  greetings # => ['Hello', 'Howdy', 'Hey']
end
```

Represent a `Hash` with `key => value` syntax:
```ruby
def say_hello(greetings: Hash[String => Integer])
  greetings # => {'Hello' => 123, 'Howdy' => 456, 'Hey' => 789})
end
```

## Return values

After your method's parameters add `-> { MyType }` to define a return value:
```ruby
def say_hello(greetings: Array[String]) -> { String }
  greetings # Raises exception if the returned value is not a String.
end
```

Return values can also be defined as `nil`able:
```ruby
def say_hello(greetings: Array[String]) -> { String | nil }
  greetings
end
```

## Syntax

### `[]` Enumerables

`Array[]` and `Hash[]` class methods represent enumerables in the context of type expressions. If you need to create a new `Array`/`Hash` then use `Array.new`/`Hash.new` or Array and Hash literals `[]` and `{}`. This is the same syntax that [RBS](https://github.com/ruby/rbs) uses and we need to get use to these class methods returning type expressions if we're ever going to have runtime types in Ruby. Additionally [RuboCop](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/HashConversion) suggests `{}` over `Hash[]` syntax for creating hashes.

### `|` Union Types / Default Value

The pipe symbol (`|`) is used in the context of type expressions to define multiple types as well as provide the default value:
- To allow multiple types separate them between pipes: `my_variable = TypeOne | TypeTwo`
- The last *value* defined becomes the default value: `my_variable = TypeOne | TypeTwo | nil`

If no default value is defined then the argument will be required.

## Performance

LowType evaluates type expressions on class load (just once) to be efficient and thread-safe. Then the defined types are checked per method call.

## Philosophy

Ruby is an amazing language **BECAUSE** it's not typed. I don't believe Ruby should ever be fully typed, this is just a module to include in some areas of your codebase where you'd like self-documentation and a little extra assurance that the right values are coming in/out.
