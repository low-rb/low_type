<p align="center"><img src="assets/LowType Logo.svg" alt="LowType logo" height="300" width="300"/></p>

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

After your method's parameters add `-> { T }` to define a return value:
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

A method that takes no arguments must include empty parameters `()` for the `-> { T }` syntax to be valid:
```ruby
def say_hello() -> { String }
  'Hello'
end
```

If you need a multi-line return type/value then I'll even let you put the `-> { T }` on multiple lines, okay? I won't judge. You are a unique flower 🌸 with your own style, your own needs. You have purpose in this world and though you may never find it, your loved ones will cherish knowing you and wish you were never gone:
```ruby
def say_farewell_with_a_long_method_name(farewell: String)
  -> {
    ::Long::Name::Space::CustomClassOne | ::Long::Name::Space::CustomClassTwo | ::Long::Name::Space::CustomClassThree
  }

  # Code that returns an instance of one of the above types.
end
```

## Instance variables

To define typed `@instance` variables use the `type_[reader, writer, accessor]` methods.  
These replicate `attr_[reader, writer, accessor]` methods but also allow you to define and check types.

### Type Reader

```ruby
type_reader name: String # Creates a public method called `name` that gets the value of @name
name # Get the value with type checking

type_reader name: String | 'Cher' # Gets the value of @name with a default value if it's `nil`
name # Get the value with type checking and return 'Cher' if the value is `nil`
```

### Type Writer

```ruby
type_writer name: String # Creates a public method called `name=(arg)` that sets the value of @name
name = 'Tim' # Set the value with type checking
```

### Type Accessor

```ruby
type_accessor name: String # Creates public methods to get or set the value of @name
name # Get the value with type checking
name = 'Tim' # Set the value with type checking

type_accessor name: String | 'Cher' # Get/set the value of @name with a default value if it's `nil`
name # Get the value with type checking and return 'Cher' if the value is `nil`
name = 'Tim' # Set the value with type checking
```

### ℹ️ Multiple Arguments

You can define multiple typed accessor methods just like you would with `attr_[reader, writer, accessor]`:
```ruby
type_accessor name: String | nil, occupation: 'Doctor', age: Integer | 33
name # => nil
occupation # => Doctor (not type checked)
age = 'old' # => Raises ArgumentTypeError
age # => 33
```

## Local variables

### `type()`

*alias: `low_type()`*

To define typed `local` variables at runtime use the `type()` method:
```ruby
my_var = type MyType | fetch_my_object(id: 123)
```

`my_var` is now type checked to be of type `MyType` when first assigned to.

## Syntax

### `[T]` Enumerables

`Array[T]` and `Hash[T]` class methods represent enumerables in the context of type expressions. If you need to create a new `Array`/`Hash` then use `Array.new()`/`Hash.new()` or Array and Hash literals `[]` and `{}`. This is the same syntax that [RBS](https://github.com/ruby/rbs) uses and we need to get use to these class methods returning type expressions if we're ever going to have runtime types in Ruby. [RuboCop](https://www.rubydoc.info/gems/rubocop/RuboCop/Cop/Style/HashConversion) also suggests `{}` over `Hash[]` syntax for creating hashes.

#### ℹ️ Equality comparisons

Class methods `Array[]`/`Hash[]` are subclassed at runtime for the type expression enumerable syntax (`[]`) to work, but only for the scope of the class that the `LowType` module is `include`d in. While `LowType::Array`/`LowType::Hash` behave just like `Array`/`Hash`, equality comparisons are be affected in some situations, but only for code under your control. Your main gotcha is:
```ruby
[].is_a?(Array) # => false
```
Because `Array`/`Hash` now refers to `LowType::Array`/`LowType::Hash`. Instead prefix `Array`/`Hash` with the top-level namespace (`::`):
```ruby
[].is_a?(::Array) # => true
```

### `|` Union Types / Default Value

The pipe symbol (`|`) is used in the context of type expressions to define multiple types as well as provide the default value:
- To allow multiple types separate them between pipes: `my_variable = TypeOne | TypeTwo`
- The last *value* defined becomes the default value: `my_variable = TypeOne | TypeTwo | nil`

If no default value is defined then the argument will be required.

### `-> { T }` Return Type

The `-> { T }` syntax is a lambda without an assignment to a local variable. This is valid Ruby that can be placed immediately after a method definition and on the same line as the method definition, to visually look like the output of that method. It's inert and doesn't run when the method is called, similar to how default values are never called if the argument is managed by LowType. Pretty cool stuff yeah? Your type expressions won't keep re-evaluating in the wild 🐴, only on class load.

### `value(T)` Value Expression

*alias: `low_value()`*

To treat a type as if it were a value, pass it through `value()` first:
```ruby
def my_method(my_arg: String | MyType | value(MyType)) # => MyType is the default value
```

## Performance

LowType evaluates type expressions on *class load* (just once) to be efficient and thread-safe. Then the defined types are checked per method call.  
However, `type()` type expressions are evaluated when they are called at *runtime* on an instance, and this may impact performance.

|                         | **Evaluation** | **Validation** | ℹ️ *Example*            |
|-------------------------|----------------|----------------|-------------------------|
| **Method param types**  | 🟢 Class load   | 🟠 Runtime     | `method(name: T)`       |
| **Method return types** | 🟢 Class load   | 🟠 Runtime     | `method() -> { T }`     |
| **Instance types**      | 🟢 Class load   | 🟠 Runtime     | `type_accessor(name: T)`|
| **Local types**         | 🟠 Runtime      | 🟠 Runtime     | `type(T)`               |

## Config

Copy and paste the following and change the defaults to configure LowType:

```ruby
LowType.configure do |config|
  config.severity_level = :error # [:error, :log] [UNRELEASED]
  config.deep_type_check = false # Set to true to type check all elements of an Array/Hash (not just the first) [UNRELEASED]
end
```

## Types

### Basic types

- `String`
- `Integer`
- `Array`
- `Hash`

### Complex types

- `Boolean` (accepts `true`/`false`) [UNRELEASED]
- `Tuple` (subclass of `Array`)
- `Status` (subclass of `Integer`) - TODO: Check integer to be a valid HTTP status code
- `Headers` (subclass of `Hash`)
- `HTML` (subclass of `String`) - TODO: Check that string is HTML
- `JSON` (subclass of `String`) - TODO: Check that string is JSON
- `XML` (subclass of `String`) - TODO: Check that string is XML

`nil` represents an optional value.

## Integrations

Because LowType is low-level it should work with method definitions in any framework out of the box. With that in mind we go a little further here at free-software-by-shadowy-figure-co to give you that extra framework-specific-special-feeling:

### Sinatra

`include LowType` in your modular `Sinatra::Base` subclass to get Sinatra specific return types.  
LowType will automatically add the necessary `content_type` [UNRELEASED] and type check the return value:

```ruby
require 'sinatra/base'
require 'low_type'

class MyApp < Sinatra::Base
  include LowType

  # A simple string response type.
  get '/' do -> { String }
    'body'
  end

  # Standard types Sinatra uses.
  get '/' do -> { Array[Integer, Hash, String] }
    [200, {}, '<h1>Hello!</h1>']    
  end

  # Types specifically for Sinatra.
  get '/' do -> { Tuple[Status, Headers, HTML] }
    [200, {}, '<h1>Hello!</h1>']    
  end
end
```

<!--### Rails [UNRELEASED]

If you still want to access Rails' `HTML` sanitizer class while in the scope of the `LowType` module, then use their full namespace `Rails::HTML`.-->

### Rubocop

Because we're living in the future, Rubocop isn't ready for us. Put the following in your `.rubocop.yml`:

```yaml
# Support LowType return value "-> { T }" syntax.
Style/TrailingBodyOnMethodDefinition:
  Enabled: false
Layout/IndentationConsistency:
  Enabled: false
Layout/MultilineBlockLayout:
  Enabled: false
Style/DefWithParentheses:
  Enabled: false
Lint/Void:
  Enabled: false
```

## Installation

Add `gem 'low_type'` to your Gemfile then:
```
bundle install
```

## Philosophy

🦆 **Duck typing is beautiful.** Ruby is an amazing language **BECAUSE** it's not typed. I don't believe Ruby should ever be fully typed, but you should be able to sprinkle in types into some areas of your codebase where you'd like self-documentation and a little reassurance that the right values are coming in/out.

🌀 **Less DSL. More types.** As much as possible LowType looks just like Ruby if it had types. There's no special method calls for the base functionality, and defining types at runtime simply uses a `type()` method which almost looks like a `type` keyword, had Ruby implemented types.

🤖 **AI makes you dumb.** AI is theoretically a cool concept but in practice capitalism just uses it to steal wealth. Chuck an [anti-AI variant](https://github.com/non-ai-licenses/non-ai-licenses) of your favourite license into your repo today!
