[![Pub Package](https://img.shields.io/pub/v/copy_with_extension_gen.svg)](https://pub.dev/packages/copy_with_extension_gen)

Provides [Dart Build System](https://pub.dev/packages/build) builder for generating `copyWith` extensions for classes annotated with [copy_with_extension](https://pub.dev/packages/copy_with_extension). For more info on this package check out my [blog article](https://oleksandrkirichenko.com/blog/dart-extensions/).

## Usage

#### In your `pubspec.yaml` file:
- Add to `dependencies` section `copy_with_extension: ^2.0.0`
- Add to `dev_dependencies` section `copy_with_extension_gen: ^2.0.1`
- Add to `dev_dependencies` section `build_runner: ^1.11.5`
- Set `environment` to at least Dart 2.12.0 version like so: `">=2.12.0 <3.0.0"`

Your `pubspec.yaml` should look like so:

```yaml
name: project_name
description: project description
version: 1.0.0

environment:
  sdk: ">=2.12.0 <3.0.0"

dependencies:
  ...
  copy_with_extension: ^2.0.0
  
dev_dependencies:
  ...
  build_runner: ^1.11.5
  copy_with_extension_gen: ^2.0.1
```

#### Annotate your class with `CopyWith` annotation:

```dart
import 'package:copy_with_extension/copy_with_extension.dart';

part 'basic_class.g.dart';

@CopyWith()
class BasicClass {
  final String id;

  BasicClass({this.id});
}
```

Make sure that you set the part file as in the example above `part 'your_file_name.g.dart';`.

#### Launch code generation:

```
flutter pub run build_runner build
```

#### The extension will be generated:

```dart
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_class.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension CopyWithExtension on BasicClass {
  BasicClass copyWith({
    String id,
  }) {
    return BasicClass(
      id: id ?? this.id,
    );
  }
}
```

## Additional features

#### Nullifying the class fields:

The `copyWith` method ignores any `null` values that are passed to it. In order to nullify the class fields, an additional `copyWithNull` function can be generated. To achieve this, simply pass an additional parameter to your class annotation `@CopyWith(generateCopyWithNull: true)`.

#### Immutable fields

If you want to prevent a particular field from modifying with `copyWith` method you can add an additional annotation like this:

```dart
@CopyWithField(immutable: true)
final int myImmutableField;
```

By adding this annotation you forcing your generated `copyWith` to always copy this field as it is, without allowing its modification.
