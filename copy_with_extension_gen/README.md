[![Pub Package](https://img.shields.io/pub/v/copy_with_extension_gen.svg)](https://pub.dev/packages/copy_with_extension_gen)

This package provides a builder for the [Dart Build System](https://pub.dev/packages/build) that generates `copyWith` extensions for classes and direct record typedefs annotated with [copy_with_extension](https://pub.dev/packages/copy_with_extension). For a detailed explanation of how this package works, check out [my blog article](https://alexander-kirsch.com/blog/dart-extensions/).

This library lets you copy immutable objects and change individual fields as follows:

```dart
myInstance.copyWith.fieldName("test") // Change a single field.

myInstance.copyWith(fieldName: "test", anotherField: "test", nullableField: null) // Change multiple fields at once.

myInstance.copyWithNull(fieldName: true, anotherField: true) // Nullify multiple fields at once.
```


## Usage

#### In your `pubspec.yaml` file

```yaml
environment:
  sdk: ">=3.7.0 <4.0.0"

dependencies:
  ...
  copy_with_extension: ^18.0.0
  
dev_dependencies:
  ...
  build_runner: ^2.10.0
  copy_with_extension_gen: ^18.0.0
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
dart run build_runner build
```

In Flutter projects, run the same command from the package root.

#### Use

```dart
const result = BasicClass(id: "id");
final copiedOne = result.copyWith.text("test"); // Results in BasicClass(id: "id", text: "test");
final copiedTwo = result.copyWith(id: "foo", text: null); // Results in BasicClass(id: "foo", text: null);
```

## Additional features

#### Records

Annotate a direct, non-nullable record typedef and generate its part file:

```dart
import 'package:copy_with_extension/copy_with_extension.dart';

part 'user.g.dart';

@CopyWith(copyWithNull: true)
typedef User = ({String name, String? note});

void main() {
  const User user = (name: 'Ada', note: 'old');
  final User copy = user.copyWith(name: 'Grace', note: null);
  final User single = user.copyWith.name('Grace');
  final User cleared = user.copyWithNull(note: true);
}
```

Copies are shallow: omitted components keep their values, and nested values are replaced whole, not traversed. Explicit `null` clears nullable components; wrong types and non-nullable `null` are rejected by the public API.

Named, positional, mixed, singleton, empty and generic records are supported. Positional components use `$1`, `$2`, etc.: `pair.copyWith($2: 3)` or `pair.copyWith.$1(4)`. Nullable receivers can use `record?.copyWith(...)`.

Options work as for classes: `skipFields` removes single-component helpers; `immutableFields` exposes only `copyWith()`. When enabled, `copyWithNull` offers flags for always-nullable types such as `T?`, not bare `T`. A bare `T` instantiated as `String?` can still be cleared through `copyWith(value: null)`.

Aliases with equal or overlapping record shapes can cause extension conflicts. Select the extension explicitly, also when a component is named `copyWith` or `copyWithNull`:

```dart
$UserCopyWith(user).copyWith(name: 'Grace');
// With a prefixed import: models.$UserCopyWith(user).copyWith(...)
```

<details>
<summary>Record limitations and edge cases</summary>

- Only direct, non-nullable record typedefs are accepted, not alias chains. Component annotations (including `@CopyWithField`), non-null `constructor` options and immediate `void` components are unsupported; functions returning `void` are allowed.
- A mutable component named `call` requires `skipFields: true`. Other conflicts with types, import prefixes or generated names require a rename or an unambiguous visible import. Generation reports detected conflicts; run analysis after generation to catch collisions with other builders.
- Imports must expose both `CopyWith` and `$CopyWithPlaceholder`. Referenced types need an unconditional, non-deferred import/export route; no imports are added for you.
- Record aliases are not distinct types. Import `show`/`hide` can also resolve [extension conflicts](https://dart.dev/language/extension-methods#api-conflicts).
- Compare record values, not identity. Bypassing types with `dynamic` or passing the reserved omission placeholder as data is outside the copying contract.

</details>

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

Set `skipFields` to prevent the library from generating `copyWith` functions for individual fields (e.g. `instance.copyWith.id("123")`), including fields inherited from superclasses. Use this per class with `@CopyWith(skipFields: true)` or configure it globally via `build.yaml` if you only want the `copyWith(...)` method.
```dart
@CopyWith(skipFields: true)
class SimpleObject {
  final String id;
  final int? intValue;

  const SimpleObject({required this.id, this.intValue});
}
```

#### Inheritance

Inherited fields are included in the generated `copyWith`. Annotation parameters apply only to the class they are written on and are not inherited — use `build.yaml` to configure them globally.

Generated members resolve from the static type of the receiver, and any member a subclass does not generate falls back to the superclass extension. This matters for `copyWithNull`: a subclass that does not enable it returns the superclass type and drops subclass fields. Generation fails with an explanatory error in most such cases, but not all — enable `copyWithNull` on every subclass that needs it, or set `copy_with_null` globally in `build.yaml`.

#### `build.yaml` configuration

You can globally configure the library's behavior in your project by adding a `build.yaml` file. This allows you to customize features such as `copyWithNull`, `skipFields`, `immutableFields`, and which annotations should be forwarded to generated parameters.

```yaml
targets:
  $default:
    builders:
      copy_with_extension_gen:
        enabled: true
        options:
          copy_with_null: true   # Default is false. Generate `copyWithNull` functions.
          skip_fields: true      # Default is false. Prevent generation of individual field methods, e.g. `instance.copyWith.id("123")`.
          immutable_fields: true # Default is false. Treat all fields as immutable unless `@CopyWithField(immutable: false)`.
          annotations:           # Names to forward (case-insensitive). A non-null list overrides defaults.
            - Deprecated         # Default is Deprecated; include it when overriding. Use [] to disable
```

By default the generator forwards only the `Deprecated` annotation. Supplying a non-null `annotations` list replaces this set, so include `Deprecated` if you still want it. Omitting `annotations` (or setting it to `null`) keeps defaults. Specifying an empty list turns off annotation propagation entirely.

## Direct builder usage

If you are wiring the builder into a custom build pipeline, import the package entrypoint directly:

```dart
import 'package:copy_with_extension_gen/copy_with_extension_gen.dart';
```

The legacy `package:copy_with_extension_gen/builder.dart` entrypoint was removed in `13.0.0`.

## How is this library better than `freezed`?

This package is a lightweight alternative for those who only need the `copyWith` functionality and prefer to keep their classes framework agnostic. You simply annotate your class with `CopyWith()` and specify the `.part` file. [`freezed`](https://pub.dev/packages/freezed) provides many additional features but requires you to structure your models in a framework‑specific way.

## How it works

Generated extensions expose a typed `copyWith` API for classes and record typedefs. Arguments retain their declared types, so normal calls reject wrong values and `null` for non-nullable fields. Field helpers are omitted when `skipFields` is set.

The private implementation uses `Object?` parameters and `$CopyWithPlaceholder` to distinguish omission from explicit `null`: omitted fields keep their values, while nullable fields can be cleared. Calls through `dynamic` bypass the public type checks. Class callables may ignore `null` for non-nullable fields, but this fallback is not guaranteed for extension types used as type arguments.

Copies are rebuilt using the selected class constructor or a record expression. When enabled, `copyWithNull` offers flags only for mutable fields whose declared types always accept `null`.
