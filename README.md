<a href="https://rubygems.org/gems/low_type" title="Install gem"><img src="https://badge.fury.io/rb/low_type.svg" alt="Gem version" height="18"></a>

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
  return nil if greetings.first == 'Goodbye'
end
```

A method that takes no arguments must include empty parameters `()` for the `-> { MyType }` syntax to be valid:
```ruby
def say_hello() -> { String }
  'Hello'
end
```

If you need a multi-line return type/value then I'll even let you put the `-> {}` on multiple lines, okay? I won't judge. You are a unique flower 🌸 with your own style, your own needs. You have purpose in this world and though you may never find it, your loved ones will cherish knowing you and wish you were never gone:
```ruby
def say_farewell_with_a_long_method_name(farewell: String)
  -> do
    ::Long::Name::Space::CustomClassOne | ::Long::Name::Space::CustomClassTwo | ::Long::Name::Space::CustomClassThree
  end

  # Code that returns an instance of one of the above types.
end
```

## Typed access methods [UNRELEASED]

To define typed `@instance` variables use the `type_[reader, writer, accessor]` methods.  
These replicate `attr_[reader, writer, accessor]` methods but also allow you to define and check types.

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

## Type assignment methods [BETA]

### `type()`

*alias: `low_type()`*

To define typed `local` variables at runtime use the `type()` method:
```ruby
my_var = type MyType | fetch_my_object(id: 123)
```

`my_var` is now type checked to be of type `MyType` when first assigned to.

### ⚠️ Important

The `type()` method must be manually enabled via `LowType.config` because of the following requirements:
- `TypeExpression`s are evaluated at *runtime* per instance (not once on *class load*) and will impact performance
- Class methods `Array[]`/`Hash[]` are subclassed at runtime for the enumerable type syntax to work (but only for the class the `LowType` module is included in).  
  While `LowType::Array/Hash` behave just like `Array/Hash`, equality comparisons may be affected in some situations
- The `type()` method dynamically adds a `.with_type=()` method to your referenced instance

### `with_type=()`

Keep in mind that you can still reassign `my_var` to reference another object of a different type, negating type checking.  
If you feel that a variable referencing an object should also control the type of that object on reassignment, then use `with_type`:

```ruby
my_var = type MyType | fetch_my_object(id: 123)
my_var.with_type = fetch_my_object(id: 456) # Raises TypeError if the new object is not of type MyType
```

### ⚠️ Important

- Single-instance objects like `nil`, `true` and `false` aren't supported by `with_type`. Your object needs to be a unique instance
- `with_type` updates the current object rather than referencing a new object. All other variables referencing the current object will reference the updated object
- Because we can't reassign `self` in Ruby we reassign the object's instance variables instead, impacting performance

## Syntax

### `[T]` Enumerables

`Array[T]` and `Hash[T]` class methods represent enumerables in the context of type expressions. If you need to create a new `Array`/`Hash` then use `Array.new`/`Hash.new` or Array and Hash literals `[]` and `{}`. This is the same syntax that [RBS](https://github.com/ruby/rbs) uses and we need to get use to these class methods returning type expressions if we're ever going to have runtime types in Ruby. [RuboCop](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/HashConversion) also suggests `{}` over `Hash[]` syntax for creating hashes.

### `|` Union Types / Default Value

The pipe symbol (`|`) is used in the context of type expressions to define multiple types as well as provide the default value:
- To allow multiple types separate them between pipes: `my_variable = TypeOne | TypeTwo`
- The last *value* defined becomes the default value: `my_variable = TypeOne | TypeTwo | nil`

If no default value is defined then the argument will be required.

### `value(T)` Value Expression

*alias: `low_value()`*

To treat a type as if it were a value, pass it through `value()` first:
```ruby
def my_method(my_arg: String | MyType | value(MyType)) # => MyType is the default value
```

## Performance

LowType evaluates type expressions on class load (just once) to be efficient and thread-safe. Then the defined types are checked per method call.

## Config

Copy and paste the following and change the defaults to configure LowType:

```ruby
LowType.configure do |config|
  config.type_assignment = false # Set to true to enable the type assignment method [BETA]
  config.deep_type_check = false # Set to true to type check all elements of an Array/Hash (not just the first) [UNRELEASED]
end
```

## Installation

Add `gem 'low_type'` to your Gemfile then:
```
bundle install
```

## Philosophy

🦆 **Duck typing is beautiful.** Ruby is an amazing language **BECAUSE** it's not typed. I don't believe Ruby should ever be fully typed, but you should be able to sprinkle in types into some areas of your codebase where you'd like self-documentation and a little reassurance that the right values are coming in/out.

🌀 **No DSL. Just types**. As much as possible LowType looks just like Ruby if it had types. There's no special method calls for the base functionality, and defining types at runtime simply uses a `type()` method which almost looks like a `type` keyword, had Ruby implemented types.

🤖 **No AI**. AI is theoretically a cool concept but in practice capitalism just uses it to steal wealth. Chuck an [anti-AI variant](https://github.com/non-ai-licenses/non-ai-licenses) of your favourite license into your repo today!
