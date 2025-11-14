# Changelog

All notable changes to this project will be documented in this file.
The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
Minor features that don't break backwards compatibiliy are released as patches.

## 1.2.0 [UNRELEASED]

### Added

- Support dynamic expressions in methods and return types at runtimem (like `type()` already does)
- `Boolean` type support
- Complex types support
- Error mode config

## 1.1.0

### Added

- Deep type checking
- Array subtype expressions

## 1.0.8

### Added

- Add `output_mode` and `output_size` config options

### Changed

- Rename `severity_level` config to `error_mode`

## 1.0.3

### Changed

- Disable union type expressions via config

## 1.0.2

### Changed

- Handle multiple classes per file
- Support main object

## 1.0.1

### Changed

- Use refinements instead of subclasses

## 1.0.0

### Changed

- Use subclasses of `Array`/`Hash` for type expression enumerable syntax (`[]`) by default (scoped to the module, not global)

### Removed

- Remove `object.with_type=()` assignment method

## 0.9.0

### Added

- Typed accessor methods

## 0.8.0

### Added

- Sinatra route return type support
- Introduce `AllowedTypeError` for situations where a framework limits available types
- Add `HTML` and `JSON` types

### Changed

- Rename "type assignment" to "local types"

## 0.7.0

### Changed

- Raise `ArgumentTypeError`, `LocalTypeError` and `ReturnTypeError` error types
- Improve error messages

## 0.6.0

### Added

- `type` and `object.with_type=()` assignment methods
- Configuration object

## 0.5.0

### Added

- Use a type as a value with `value()`/`low_value()` helper methods

### Fixed

- Make return type specific error

## 0.4.0

### Added

- Support typed return values

## 0.3.0

### Added

- Support for `Array[T]` enumerable type
- Support for `Hash[T]` enumerable type

## 0.2.0

### Added

- Support for class methods
- Support for private methods

### Changed

- Reuse core Ruby error types
- Ignore untyped methods for better performance
- Use an abstract syntax tree for more accurate method metadata
- Use Ruby's Prism parser
