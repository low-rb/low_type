# Boolean and Enum Types - GSoC Implementation Guide

## 1. Where to Implement

### Boolean Type
| File | Action |
|------|--------|
| `lib/types/boolean.rb` | **CREATE** - Custom Boolean type (replace TypeFactory approach) |
| `lib/types/complex_types.rb` | **MODIFY** - Replace `TypeFactory.complex_type(Object)` with require and reference |
| `lib/low_type.rb` | **NO CHANGE** - Types are loaded via `complex_types.rb` |

### Enum Type
| File | Action |
|------|--------|
| `lib/types/enum.rb` | **CREATE** - Enum class with `.[]` and Definition inner class |
| `lib/types/complex_types.rb` | **MODIFY** - Add Enum to exports (Enum is NOT in COMPLEX_TYPES - it's a type constructor) |
| `lib/queries/type_query.rb` | **MODIFY** - Add `enum_definition?` and `type?` support |
| `lib/expressions/type_expression.rb` | **MODIFY** - Add `type_matches_value?` branch for match?-capable objects; update `valid_types` |

### Require Chain
- `lib/low_type.rb` → `lib/types/complex_types.rb`
- `complex_types.rb` must `require_relative 'boolean'` and `require_relative 'enum'`

---

## 2. Step-by-Step Implementation Plan

### Phase 1: Boolean (Simpler - do first)

**Step 1.1** - Create `lib/types/boolean.rb` with custom `match?`:
- Boolean cannot use `TypeFactory.complex_type(Object)` because Object's `match?` would incorrectly match or reject (TrueClass/FalseClass are not Object by instance_of)
- Boolean must explicitly check `value == true || value == false`

**Step 1.2** - Update `lib/types/complex_types.rb`:
- Remove `Boolean = TypeFactory.complex_type(Object)`
- Add `require_relative 'boolean'`
- Add `Boolean` to COMPLEX_TYPES (keep the constant)

**Step 1.3** - Add specs in `spec/units/types/boolean_spec.rb` and integration in `spec/fixtures/` + `spec/features/`

---

### Phase 2: Enum

**Step 2.1** - Create `lib/types/enum.rb`:
- Define `Enum` module/class with `def self.[](*allowed_values)`
- Return `Enum::Definition.new(allowed_values)` - an object that holds the set of allowed values
- `Enum::Definition` must implement `match?(value:)` → `allowed_values.include?(value)`
- `Enum::Definition` must implement `inspect` or `to_s` for error messages (`valid_types`)

**Step 2.2** - Update `lib/queries/type_query.rb`:
- Add `enum_definition?(expression:)` → `expression.is_a?(Low::Types::Enum::Definition)` (use `defined?` guard for load order)
- Update `type?(expression)` to include `enum_definition?(expression:)`
- Update `complex_type?` - Enum::Definition is NOT a complex_type (it's a type structure); `type?` covers it

**Step 2.3** - Update `lib/expressions/type_expression.rb`:
- In `type_matches_value?`, add branch BEFORE the Class check:
  ```ruby
  return type.match?(value:) if type.respond_to?(:match?)
  ```
- In `valid_types`, add branch for Enum::Definition to produce `"Enum[1, 2, 3]"`-style output
- In `valid_subtype`, handle Enum::Definition

**Step 2.4** - Update `lib/definitions/evaluator.rb`:
- `cast_type_expression` already uses `TypeQuery.type?` - once we add enum_definition?, Enum values will flow through
- Ensure `Evaluator` has access to `Enum` - it's in `Types` which is included. Add `require_relative '../types/enum'` in evaluator or complex_types

**Step 2.5** - Wire Enum into the includer's namespace:
- `klass.extend Low::Types` (already in low_type.rb) - we need `Enum` to be available
- Check `lib/types/complex_types.rb` - it does `module Types` and defines constants. Add `Enum` there or require it so it's under `Low::Types::Enum`

**Step 2.6** - Add specs

---

### Phase 3: Integration and Edge Cases

**Step 3.1** - Support `Enum` in unions: `def foo(x: Enum[:a, :b, :c] | nil)`
**Step 3.2** - Support `Enum` in type_accessor: `type_accessor status: Enum[:draft, :published]`
**Step 3.3** - Support `Array[Enum[...]]` if needed (typed_array? - Enum::Definition in array)
**Step 3.4** - Update README and CHANGELOG

---

## 3. Code to Reuse or Modify

### Reuse As-Is
- `TypeExpression#validate!` - no changes; it delegates to `type_matches_value?`
- `Evaluator#cast_type_expression` - works once TypeQuery.type? includes enum
- `Redefiner` - no changes
- `type_accessors.rb` - works if `cast_type_expression` handles Enum
- `expression_helpers.rb` - `type()` and `value()` - check if they need Enum support

### Modify
- **TypeFactory** - Do NOT use for Boolean. Create dedicated Boolean.
- **Status** - Use as reference for a type with custom behavior. Status uses `extend ComplexType` and `.[]` for values.
- **complex_type.rb** - The `match?` pattern is what Boolean and Enum::Definition need.

### TypeQuery.type? Flow
Current: `basic_type? || complex_type?`
New: `basic_type? || complex_type? || enum_definition?`

### Enum constant resolution
`Enum` must be in scope when default values are evaluated. The Evaluator `include`s `Low::Types`, so it has `Enum`. User classes get `extend Low::Types` via the `included` hook, so `Enum` resolves in method defaults (same as `Status`, `Boolean`). If needed, users can write `Low::Types::Enum[:a, :b]` explicitly.

### type_matches_value? Flow
Current:
1. If Class → complex_type? → match? else value.class
2. If TypeExpression → validate!

New:
1. If responds_to?(:match?) → type.match?(value:)  # Catches Enum::Definition, Boolean
2. If Class → ...
3. If TypeExpression → ...

**Important:** `respond_to?(:match?)` must come first so Enum::Definition (not a Class) is handled. Boolean IS a Class, so it would be caught by the Class branch - but Boolean uses the complex_type path which calls match?. So we need:
- For Enum::Definition (not a Class): new branch with respond_to?(:match?)
- For Boolean (Class in COMPLEX_TYPES): existing Class branch works - it calls type.match?(value:)

So we only need the respond_to? branch for Enum::Definition. Boolean is already covered.

---

## 4. Example Implementation

### lib/types/boolean.rb

```ruby
# frozen_string_literal: true

require_relative 'complex_type'

module Low
  module Types
    # Accepts only true or false. Use instead of TrueClass | FalseClass.
    class Boolean
      extend ComplexType

      def self.match?(value:)
        value == true || value == false
      end
    end
  end
end
```

**Note:** Boolean cannot inherit from Object via TypeFactory because we need custom match? logic. We use a plain Class and extend ComplexType. But ComplexType's match? does:
```ruby
value.instance_of?(self.class) || value.instance_of?(superclass)
```
For Boolean, self.class is Class, superclass is Object. true.instance_of?(Object) is false. So we MUST override match? in Boolean. The implementation above does that.

### lib/types/enum.rb

```ruby
# frozen_string_literal: true

module Low
  module Types
    # Enum[val1, val2, ...] creates a type that accepts only the listed values.
    # Usage: def foo(status: Enum[:draft, :published, :archived])
    module Enum
      class Definition
        attr_reader :allowed_values

        def initialize(allowed_values)
          @allowed_values = allowed_values.freeze
        end

        def match?(value:)
          @allowed_values.include?(value)
        end

        def inspect
          "Enum[#{@allowed_values.map(&:inspect).join(', ')}]"
        end
      end

      def self.[](*allowed_values)
        Definition.new(allowed_values)
      end
    end
  end
end
```

### lib/types/complex_types.rb (modified)

```ruby
# frozen_string_literal: true

require_relative '../factories/type_factory'
require_relative 'boolean'
require_relative 'enum'
require_relative 'status'

module Low
  module Types
    COMPLEX_TYPES = [
      Boolean,
      Headers = TypeFactory.complex_type(Hash),
      HTML = TypeFactory.complex_type(String),
      JSON = TypeFactory.complex_type(String),
      Status,
      Tuple = TypeFactory.complex_type(Array),
      XML = TypeFactory.complex_type(String)
    ].freeze
  end
end
```

### lib/queries/type_query.rb (modified)

```ruby
def type?(expression)
  basic_type?(expression:) || complex_type?(expression:) || enum_definition?(expression:)
end

def enum_definition?(expression:)
  expression.is_a?(Low::Types::Enum::Definition)
end
```

### lib/expressions/type_expression.rb (modified)

In `type_matches_value?`, add at the top (before Class check):

```ruby
def type_matches_value?(type:, value:, proxy:)
  # Enum::Definition and other type structures with match?
  return type.match?(value:) if type.respond_to?(:match?) && !type.instance_of?(Class)

  if type.instance_of?(Class)
    # ... existing code
  end
  # ...
end
```

**Why `!type.instance_of?(Class)`?** Classes also respond_to?(:match?) when they extend ComplexType. We want to keep the existing Class handling for complex types (which calls match? explicitly). The new branch is for non-Class objects like Enum::Definition.

Actually, we could simplify: `return type.match?(value:) if type.respond_to?(:match?)` - and it would work for both. For Class with ComplexType, we'd call match? which is correct. For Enum::Definition, we'd call match?. So we can use just `respond_to?(:match?)` and it might even simplify the Class branch. Let me check - for a normal Class like String, String.respond_to?(:match?) - in Ruby 3, Class doesn't have match? by default. So we'd get false and fall through to the Class branch. Good. For Boolean, Boolean.respond_to?(:match?) is true (from ComplexType). So we'd call Boolean.match?(value:) - correct! For Enum::Definition, respond_to?(:match?) is true - correct. So we can put `return type.match?(value:) if type.respond_to?(:match?)` first and it handles both. The existing Class branch would then only handle Classes that don't have match? (basic types like String, Integer). For those we use `type == value.class`. Perfect.

In `valid_types` and `valid_subtype`, add:

```ruby
# In valid_types, in the @types.map block:
elsif type.respond_to?(:inspect) && !type.is_a?(Array) && !type.instance_of?(Class)
  type.inspect
```

Actually, for Enum::Definition we want the custom inspect. The else branch does `type.inspect.to_s.delete_prefix('Low::Types::')`. For Enum::Definition, inspect returns "Enum[1, 2, 3]". We don't need to delete prefix. So we could add:
```ruby
elsif type.is_a?(Low::Types::Enum::Definition)
  type.inspect
```
Or use respond_to? for extensibility. The current else would call type.inspect.to_s - for Enum::Definition that gives "Enum[1, 2, 3]". The delete_prefix would leave it unchanged since it doesn't start with "Low::Types::". So actually the existing code might work! Let me check: `type.inspect.to_s.delete_prefix('Low::Types::')` for Enum::Definition → "Enum[1, 2, 3]". Good.

For valid_subtype, it handles TypeExpression and else does `subtype.to_s.delete_prefix(...)`. Enum::Definition would hit else, to_s by default is inspect, so we'd get "Enum[1, 2, 3]". Good. But we should add inspect method to Enum::Definition that's descriptive. Done above.

---

## 5. Edge Cases to Handle

### Boolean
| Edge Case | Handling |
|-----------|----------|
| `nil` | Handled by validate! - nil returns early if default_value.nil? or raises if required |
| `0` | Boolean.match?(0) → false. Reject. ✓ |
| `"true"` | Boolean.match?("true") → false. Reject. ✓ |
| `true`, `false` | Accept. ✓ |

### Enum
| Edge Case | Handling |
|-----------|----------|
| `Enum[]` (empty) | Rejects all values. Document or raise at definition time? Prefer: allow, match? returns false for everything. |
| `Enum[1, 1, 1]` (duplicates) | include? works. Or use Set for clarity. Keep as Array for simplicity. |
| `Enum[nil]` | `def foo(x: Enum[nil])` - allows only nil. include?(nil) works. |
| Value not in list | match? returns false, validate! raises. ✓ |
| `Enum[:a, :b] | nil` | Union - default_value is nil. Works via existing union support. |
| `Array[Enum[:a,:b]]` | typed_array? checks expression.first - Enum::Definition is not a basic type or TypeExpression. Need to extend typed_array? to allow Enum::Definition in arrays. For v1, document as future work. |
| `type_accessor status: Enum[:draft, :published]` | type_accessors cast_type_expression - TypeQuery.type? must be true. ✓ |
| `type Enum[:a, :b] | fetch_default` | type() in expression_helpers - passes to validate!. type_expression would be from Evaluator... type() is for local vars, evaluated at runtime. The expression is built from the right-hand side. Need to ensure Enum works in Expressions gem's chain. Enum[1,2,3] | default - the | is from union_types (Object) or Expressions. When we have Enum[1,2,3], that's the receiver of |. So Enum.defined? is needed. The class that includes LowType gets `extend Low::Types` - does that add Enum? Low::Types is a module. When we extend it, we get the constants. So Low::Types::Enum is available as Enum if the class is in a context where Enum resolves. The user's code runs in their class. They need to have `Enum` in scope. Is Enum defined at top level? No - it's Low::Types::Enum. So the user would need to write `def foo(x: Low::Types::Enum[:draft, :published])` OR we need to make Enum available. Looking at Status - it's in Types, and in Sinatra example they use `Tuple[Status, Headers, HTML]`. So Status is available. That means the Types module constants are exposed. When you extend a module, you get its constants as class methods... No, extend adds instance methods. For constants, the class would need to include or the user needs to reference Low::Types::Status. Let me check - in the Sinatra app.rb example, they use `Tuple[Status, Headers, HTML]`. So Status must be in scope. The class does `include LowType`. So it gets `extend Low::Types`. The Types module has `Status` as a constant. When you extend a module, the module's constants aren't automatically in scope - you'd need `include Low::Types` or the constants would be `Low::Types::Status`. Oh, but `klass.extend Low::Types` - when you extend, the module becomes the singleton class's superclass. So for constant lookup, the class looks in self, then singleton class ancestors. The singleton class has Low::Types in its ancestry. So constants defined in Low::Types would be found! So Enum, Status, Boolean would all be found as constants when the class does method definition. Good. |

### General
| Edge Case | Handling |
|-----------|----------|
| `config.type_checking = false` | Redefiner uses untyped_methods - no validation. ✓ |
| Error message for invalid Boolean | "Valid types: 'Boolean'" - valid_types for Boolean. ✓ |
| Error message for invalid Enum | "Valid types: 'Enum[:draft, :published]'" - need valid_types. Enum::Definition.inspect. ✓ |

---

## 6. Testing Strategy

### Unit Tests

**spec/units/types/boolean_spec.rb**
```ruby
RSpec.describe Low::Types::Boolean do
  describe '.match?' do
    it 'accepts true' do
      expect(described_class.match?(value: true)).to be true
    end
    it 'accepts false' do
      expect(described_class.match?(value: false)).to be true
    end
    it 'rejects nil' do
      expect(described_class.match?(value: nil)).to be false
    end
    it 'rejects string "true"' do
      expect(described_class.match?(value: 'true')).to be false
    end
    it 'rejects integer 0' do
      expect(described_class.match?(value: 0)).to be false
    end
  end
end
```

**spec/units/types/enum_spec.rb**
```ruby
RSpec.describe Low::Types::Enum do
  describe '.[]' do
    it 'returns a Definition' do
      expect(described_class[1, 2, 3]).to be_a(Low::Types::Enum::Definition)
    end
    it 'Definition#match? accepts allowed values' do
      defn = described_class[:a, :b, :c]
      expect(defn.match?(value: :a)).to be true
      expect(defn.match?(value: :b)).to be true
    end
    it 'Definition#match? rejects disallowed values' do
      defn = described_class[:a, :b, :c]
      expect(defn.match?(value: :d)).to be false
    end
    it 'inspect returns readable form' do
      defn = described_class[:draft, :published]
      expect(defn.inspect).to include('Enum')
      expect(defn.inspect).to include('draft')
    end
  end
end
```

### Integration Tests (Fixtures + Features)

**spec/fixtures/boolean_and_enum.rb**
```ruby
# frozen_string_literal: true

require_relative '../../lib/low_type'

class BooleanAndEnum
  include LowType

  def boolean_arg(flag: Boolean)
    flag
  end

  def boolean_with_default(flag: Boolean | true)
    flag
  end

  def enum_arg(status: Low::Types::Enum[:draft, :published, :archived])
    status
  end

  def enum_with_default(status: Low::Types::Enum[:draft, :published] | :draft)
    status
  end
end
```

**spec/features/boolean_and_enum_spec.rb**
- Test Boolean accepts true/false, rejects others, raises with clear message
- Test Boolean with default
- Test Enum accepts allowed values, rejects others
- Test Enum with default
- Test Enum | nil

### TypeQuery and TypeExpression
- Add spec that TypeQuery.type?(enum_definition) returns true
- Add spec that TypeExpression validates Enum correctly (or rely on integration)
