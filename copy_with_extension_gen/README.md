[![Pub Package](https://img.shields.io/pub/v/copy_with_extension_gen.svg)](https://pub.dev/packages/copy_with_extension_gen)

This package provides a builder for the [Dart Build System](https://pub.dev/packages/build) that generates `copyWith` extensions for classes annotated with [copy_with_extension](https://pub.dev/packages/copy_with_extension). For a detailed explanation of how this package works, check out [my blog article](https://alexander-kirsch.com/blog/dart-extensions/).

This library lets you copy immutable objects and change individual fields as follows:

```dart
myInstance.copyWith.fieldName("test") // Change a single field.

myInstance.copyWith(fieldName: "test", anotherField: "test", nullableField: null) // Change multiple fields at once.

myInstance.copyWithNull(fieldName: true, anotherField: true) // Nullify multiple fields at once.
```


## Usage

#### In your `pubspec.yaml` file
- Add to `dependencies` section `copy_with_extension: ^9.0.0`
- Add to `dev_dependencies` section `copy_with_extension_gen: ^9.0.0`
- Add to `dev_dependencies` section `build_runner: ^2.6.0`
- Set `environment` to at least Dart `3.0.0` version like so: `">=3.0.0 <4.0.0"`

Your `pubspec.yaml` should look like this:

```yaml
environment:
  sdk: ">=3.0.0 <4.0.0"

dependencies:
  ...
  copy_with_extension: ^9.0.0
  
dev_dependencies:
  ...
  build_runner: ^2.6.0
  copy_with_extension_gen: ^9.0.0
```

#### Annotate your class with `CopyWith` annotation

```dart
import 'package:copy_with_extension/copy_with_extension.dart';

part 'basic_class.g.dart';

@CopyWith()
class BasicClass {
  final String id;
  final String? text;

  const BasicClass({ required this.id, this.text});
}
```

Make sure that you set the part file as shown in the example above: `part 'your_file_name.g.dart';`.

#### Launch code generation

```bash
flutter pub run build_runner build
```

#### Use

```dart
const result = BasicClass(id: "id");
final copiedOne = result.copyWith.text("test"); // Results in BasicClass(id: "id", text: "test");
final copiedTwo = result.copyWith(id: "foo", text: null); // Results in BasicClass(id: "foo", text: null);
```

## Additional features

#### Change Multiple Fields Simultaneously
Modify several fields at once with the `copyWith()` function:
```dart
myInstance.copyWith(fieldName: "test", anotherField: "test");
```

#### Nullifying instance fields

Generate a `copyWithNull` function to nullify class fields. Enable this per class by setting `copyWithNull` to `true`, or configure it globally in `build.yaml`:
```dart
@CopyWith(copyWithNull: true)
class MyClass {
  ...
}
```

#### Protect Immutable Fields

Prevent modification of specific fields by using:

```dart
@CopyWithField(immutable: true)
final int myImmutableField;
```

This enforces that the generated `copyWith` and `copyWithNull` methods copy this field without allowing modifications.

#### Custom Constructor Name

Set `constructor` if you want to use a named constructor, e.g. a private one. The generated fields will be derived from this constructor.

```dart
@CopyWith(constructor: "_")
class SimpleObjectPrivateConstructor {
  @CopyWithField(immutable: true)
  final String? id;
  final int? intValue;

  const SimpleObjectPrivateConstructor._({this.id, this.intValue});
}
```

#### Skipping generation of `copyWith` functionality for individual fields

Set `skipFields` to prevent the library from generating `copyWith` functions for individual fields (e.g. `instance.copyWith.id("123")`). Use this per class with `@CopyWith(skipFields: true)` or configure it globally via `build.yaml` if you only want the `copyWith(...)` method.
```dart
@CopyWith(skipFields: true)
class SimpleObject {
  final String id;
  final int? intValue;

  const SimpleObject({required this.id, this.intValue});
}
```

#### `build.yaml` configuration

You can globally configure the library's behavior in your project by adding a `build.yaml` file. This allows you to customize features such as `copyWithNull`, `skipFields`, and which annotations should be forwarded to generated parameters.

```yaml
targets:
  $default:
    builders:
      copy_with_extension_gen:
        enabled: true
        options:
          copy_with_null: true # Default is false. Generate `copyWithNull` functions.
          skip_fields: true    # Default is false. Prevent generation of individual field methods, e.g. `instance.copyWith.id("123")`.
          annotations:        # Names to forward (case-insensitive). Overrides defaults when provided.
            - Deprecated      # Default is Deprecated; include it when overriding. Use [] to disable
```

By default the generator forwards only the `Deprecated` annotation. Supplying the `annotations` list replaces this set, so include `Deprecated` if you still want it. Specifying an empty list turns off annotation propagation entirely.

## How is this library better than `freezed`?

This package is a lightweight alternative for those who only need the `copyWith` functionality and prefer to keep their classes framework agnostic. You simply annotate your class with `CopyWith()` and specify the `.part` file. [`freezed`](https://pub.dev/packages/freezed) provides many additional features but requires you to structure your models in a framework‑specific way.

## How it works

The generated `*.g.dart` file creates an extension on your class that exposes a `copyWith` getter. Calling this getter returns a private proxy class that is both callable and provides methods for each mutable field when `skipFields` is not set.

Each parameter of the proxy's `call` method is typed as `Object?` and defaults to a special constant `$CopyWithPlaceholder`. This sentinel value lets the proxy distinguish between a parameter that was **not** supplied and one that was set to `null`. Fields whose parameter equals `$CopyWithPlaceholder` retain their current value, while any other argument replaces the field value. This approach enables safe nullification of nullable fields without affecting non-nullable ones.

When `copyWithNull` is enabled, an additional `copyWithNull` method is generated to nullify fields by passing boolean flags. The proxy class used by `copyWith` internally invokes the appropriate constructor with the updated field values after resolving these placeholders.