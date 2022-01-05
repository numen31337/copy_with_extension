[![Pub Package](https://img.shields.io/pub/v/copy_with_extension_gen.svg)](https://pub.dev/packages/copy_with_extension_gen)

Provides [Dart Build System](https://pub.dev/packages/build) builder for generating `copyWith` extensions for classes annotated with [copy_with_extension](https://pub.dev/packages/copy_with_extension). For more information on how this package works, see [my blog article](https://oleksandrkirichenko.com/blog/dart-extensions/).

This library allows you to copy instances of immutable classes modifying specific fields like so:

```dart
myInstance.copyWith.fieldName("test") // Change a single field.

myInstance.copyWith(fieldName: "test", anotherField: "test", nullableField: null) // Change multiple fields at once.

myInstance.copyWithNull(fieldName: true, anotherField: true) // Nullify multiple fields at once.
```


## Usage

#### In your `pubspec.yaml` file:
- Add to `dependencies` section `copy_with_extension: ^4.0.0`
- Add to `dev_dependencies` section `copy_with_extension_gen: ^4.0.0`
- Add to `dev_dependencies` section `build_runner: ^2.1.7`
- Set `environment` to at least Dart `2.12.0` version like so: `">=2.12.0 <3.0.0"`

Your `pubspec.yaml` should look like so:

```yaml
name: project_name
description: project description
version: 1.0.0

environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  ...
  copy_with_extension: ^4.0.0
  
dev_dependencies:
  ...
  build_runner: ^2.1.7
  copy_with_extension_gen: ^4.0.0
```

#### Annotate your class with `CopyWith` annotation:

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

Make sure that you set the part file as in the example above `part 'your_file_name.g.dart';`.

#### Launch code generation:

```
flutter pub run build_runner build
```

#### Use

```dart
const result = BasicClass(id: "id")
final copiedOne = result.copyWith.text("test") // Results in BasicClass(id: "id", text: "test");
final copiedTwo = result.copyWith(id: "foo", text: null) // Results in BasicClass(id: "foo", text: null);
```

## Additional features

#### Change several fields at once with copyWith()

You can modify multiple fields at once using `copyWith` as a function like so: `myInstance.copyWith(fieldName: "test", anotherField: "test")`. Passing the `null` value to `non-nullable` fields will be ignored.

#### Nullifying instance fields:

In order to nullify the class fields, an additional `copyWithNull` function can be generated. To make use of it, pass an additional parameter to your class annotation `@CopyWith(generateCopyWithNull: true)`.

#### Immutable fields

If you want to prevent a particular field from modifying with `copyWith` method you can add an additional annotation like this:

```dart
@CopyWithField(immutable: true)
final int myImmutableField;
```

By adding this annotation you forcing your generated `copyWith` to always copy this field as it is, without exposing it in the function interface.
