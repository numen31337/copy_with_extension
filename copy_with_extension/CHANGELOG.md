## 4.0.2
* Updating `analyzer` to `>=2.0.0 <5.0.0`

## 4.0.1
* [Fix](https://github.com/numen31337/copy_with_extension/issues/45) for passing `null` into `copyWith` function for non-nullable values.

## 4.0.0
* **BREAKING** `copyWith` function now correctly supports nullification of nullable fields like so `copyWith(id: null)`.
* **BREAKING** `CopyWith` annotation for named constructor `namedConstructor` is renamed to `constructor` to be in sync with [json_serializable](https://pub.dev/packages/json_serializable).

## 3.0.0
* Updating `analyzer` to `>=2.0.0 <4.0.0`
* Named constructor support.
* Better error reporting.
* Introduction of the new `copyWith` function with nullability support that can be used like so: `myInstance.copyWith.value("newValue")`. The old functionality is still available.
* **BREAKING** `generateCopyWithNull` is renamed to `copyWithNull`.

## 2.0.3 Dependency update
* Updating `analyzer` to `^2.0.0`

## 2.0.2 Bugfix
* Fix generation of generics with nullable types (thanks [@josiahsrc](https://github.com/josiahsrc)).

## 2.0.1 Null Safety
* Updating build and source_gen dependencies.

## 2.0.0 Null Safety
* Updating dependencies.

## 2.0.0-nullsafety.1 Null Safety
* Introduces support of null safety.

## 1.4.0 Improving generic compatibility
* Fixes issue with generating code for some classes with generic type parameters.

## 1.3.1 README Update
* Update README.md

## 1.3.0 Immutable Fields
* Fixes the `boolean-expression-must-not-be-null-exception` issue
* Introduces `immutable` field annotation

## 1.2.0 Generic Types

* Introducing Generic Types Supports

## 1.1.0 copyWithNull

* Introducing the `copyWithNull` function.

## 1.0.8 Analyzer rules

* Suppresses some of the analyzer's rules as we do not support generic types yet.

## 1.0.7 Extension name fix

* Creates a unique extension name for each class.

## 1.0.6 Minor corrections

* Minor metadata and description corrections.

## 1.0.0 Initial release

* Lets you generate a `copyWith` extension for objects annotated with `@CopyWith()`.