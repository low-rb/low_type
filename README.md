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

A method that takes no arguments must include empty parameters `()` for the `-> { MyType }` syntax to be valid:
```ruby
def say_hello() -> { String | 'Hello' }
  greetings
end
```

If you need a multi-line return type/value then I’ll even let you put the `-> {}` on multiple lines, okay? I won't judge. You are a unique flower 🌸 with your own style, your own needs. You have purpose in this world and though you may never find it, your loved ones will cherish knowing you and wish you were never gone:
```ruby
def say_farewell_with_a_long_method_name(farewell: String)
  -> do
    ::Long::Name::Space::CustomString | get_default_value_with_a_long_method_name()
  end

  farewell
end
```

## Type Access methods [UNRELEASED]

Replace `attr_[reader, writer, accessor]` methods with `type_[reader, writer, accessor]` to also define types:

### Type Reader

```ruby
type_reader :name, String # Creates a public method called `name` that gets the value of @name
type_reader :name, String | 'Cher' # Gets the value of @name with a default value if it's `nil`
```

### Type Writer

```ruby
type_writer :name, String # Creates a public method called `name=(arg)` that sets the value of @name
```

### Type Accessor

```ruby
type_accessor :name, String # Creates public methods to get or set the value of @name
name # Get the value with type checking
name = 'Tim' # Set the value with type checking

type_accessor :name, String | 'Cher' # Get/set the value of @name with a default value if it's `nil`
```

## Type Assignment method [UNRELEASED]

To define instance/local variable types at runtime use the `type()` method like so:
```ruby
my_var = type MyType | nil
```

`my_var` will be type checked when assigned to from now on:

```ruby
my_var = AnotherType.new # Raises InvalidType error.
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

**Duck typing is beautiful.** Ruby is an amazing language **BECAUSE** it's not typed. I don't believe Ruby should ever be fully typed, this is just a module to include in some areas of your codebase where you'd like self-documentation and a little extra assurance that the right values are coming in/out.

**No DSL. Just types**. As much as possible LowType looks just like Ruby if it had types. There’s no special method calls for the base functionality, and defining types at runtime simply uses a `type()` method which almost looks like a `type` keyword, had Ruby implemented types.
