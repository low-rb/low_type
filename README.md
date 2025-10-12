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

Add square brackets (`[]`) after your class to make it an enumerable collection of that class:
```ruby
def say_hello(greetings: String[])
  greetings # => ['Hello', 'Howdy', 'Hey']
end
```

Represent a `Hash` with the `KeyValue` utility class:
```ruby
def say_hello(greetings: KeyValue[String => Integer])
  greetings # => {'Hello' => 123, 'Howdy' => 456, 'Hey' => '789'})
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

The `[]` class method is used in the context of type expressions to represent an enummerable collection (`Array`/`Hash`) of that object type. Anyone can define a `[]` class method on their class but luckily for us it's usually on a "factory" or "utility" class and not an enumerbale class so there's not much overlap.

### `|` Union Types / Default Value

The pipe symbol (`|`) is used in the context of type expressions to define multiple types as well as provide the default value:
- To allow multiple types separate them between pipes: `my_variable = TypeOne | TypeTwo`
- The last *value* defined becomes the default value: `my_variable = TypeOne | TypeTwo | nil`

If no default value is defined then the argument will be required.

# Philosophy

Ruby is an amazing language **BECAUSE** it's not typed. I don't believe Ruby should ever be fully typed, this is just a module to include in some areas of your codebase where you'd like self-documentation and a little extra assurance that the right values are coming in/out.
