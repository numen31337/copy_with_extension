import 'package:meta/meta.dart' show immutable;
import 'package:copy_with_extension/copy_with_extension.dart';

/// Make sure that `part` is specified, even before launching the builder
/// part 'example.g.dart';

@immutable
@CopyWith()
class SimpleObject {
  final String id;
  final int? value;

  /// Make sure that constructor has named parameters (wrapped in curly braces)
  const SimpleObject({required this.id, this.value});
}

@immutable
@CopyWith(namedConstructor: "_")
class SimpleObjectPrivateConstructor {
  final String id;
  final int? value;

  const SimpleObjectPrivateConstructor._({required this.id, this.value});
}

@immutable
@CopyWith(copyWithNull: true)
class SimpleObjectExposeWithNullAndWithValues {
  final String id;
  final int? value;
  @CopyWithField(immutable: true)
  final int immutableField;

  const SimpleObjectExposeWithNullAndWithValues({
    required this.id,
    this.value,
    required this.immutableField,
  });
}
