import 'package:copy_with_extension/copy_with_extension.dart';

/// The internal representation of parameters entered by the library's user.
class CopyWithFieldAnnotation implements CopyWithField {
  const CopyWithFieldAnnotation({
    required this.immutable,
  });

  const CopyWithFieldAnnotation.defaults() : this(immutable: false);

  @override
  final bool immutable;
}
