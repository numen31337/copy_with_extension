## 10.0.0
* Updating `analyzer` to `^8.0.0`
* Updating `source_gen` to `^4.0.0`
* Updating `build` to `^4.0.0`

## 9.1.1
* Fix constructor parameter resolution when initializers reference parameters or super constructors.

## 9.1.0
* Added `immutableFields` option to treat class fields as immutable by default.
* Forward annotations (e.g., `@Deprecated`) to generated `copyWith` parameters.
* Preserve type aliases.
* Added support for redirection constructors.

## 9.0.0
* **BREAKING** Dynamic fields are treated as nullable, affecting generated `copyWith` signatures.
* Added robust inheritance support enabling `copyWith` across parent and child classes

## 8.0.0
* **BREAKING** Private constructor parameters are now treated as immutable to avoid [invalid](https://github.com/numen31337/copy_with_extension/issues/85) `copyWith` parameter names.
* **BREAKING** Field annotations are [inherited](https://github.com/numen31337/copy_with_extension/issues/70) from parent classes.

## 7.1.0
* Added namespace support for classes using import prefixes.
* Added comments and tests for clarity.

## 7.0.0
* Migrated to the new analyzer `element2` APIs.
* Updating `analyzer` to `^7.0.0`
* Updating `source_gen` to `^3.0.0`

## 6.0.1
* Updating `analyzer` to `^7.0.0`
* Updating `source_gen` to `^2.0.0`

## 6.0.0
* **BREAKING** The `copyWith` function no longer accepts `null` for non-nullable fields to prevent ambiguity and errors.

## 5.0.4
* Updating `analyzer` to `>=2.0.0 <7.0.0` (thanks [@shilangyu](https://github.com/shilangyu)).

## 5.0.3
* Updating `sdk` to `>=3.0.0 <4.0.0`

## 5.0.2
* [Fix](https://github.com/numen31337/copy_with_extension/issues/79) Allow having a nullable constructor parameter with a fallback for a non-nullable class field.

## 5.0.1
* [Fix](https://github.com/numen31337/copy_with_extension/issues/72) Warnings when using the `?` operator on a dynamic type.
* [Fix](https://github.com/numen31337/copy_with_extension/issues/75) Warnings when using the `!` operator on a non-nullable type.
* [Fix](https://github.com/numen31337/copy_with_extension/issues/74) Crash when object contains a dynamic field that is `null`.

## 5.0.0
* Allow positional constructor parameters (thanks [@mrgnhnt96](https://github.com/mrgnhnt96)).
* Ability to define library default settings globally (thanks [@mrgnhnt96](https://github.com/mrgnhnt96)).

## 4.0.4
* Updating `analyzer` to `>=2.0.0 <6.0.0`

## 4.0.3
* Suppressing [lint warnings](https://github.com/numen31337/copy_with_extension/issues/54) for `library_private_types_in_public_api`.
* Classes that are declared as private will [get a private](https://github.com/numen31337/copy_with_extension/issues/50) `copyWith` extension.

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
* Introduces support for null safety.

## 1.4.0 Improving generic compatibility
* Fixes an issue with generating code for some classes with generic type parameters.

## 1.3.1 README Update
* Update README.md

## 1.3.0 Immutable Fields
* Fixes the `boolean-expression-must-not-be-null-exception` issue
* Introduces the `immutable` field annotation

## 1.2.0 Generic Types

* Introducing support for generic types

## 1.1.0 copyWithNull

* Introducing the `copyWithNull` function.

## 1.0.8 Analyzer rules

* Suppresses some of the analyzer's rules as we do not support generic types yet.

## 1.0.7 Extension name fix

* Creates a unique extension name for each class.

## 1.0.6 Minor corrections

* Minor metadata and description corrections.

## 1.0.0 Initial release

* Allows you to generate a `copyWith` extension for objects annotated with `@CopyWith()`.