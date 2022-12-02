import 'package:copy_with_extension/copy_with_extension.dart';

class CopyWithFieldAnnotation implements CopyWithField {
  const CopyWithFieldAnnotation({
    required this.immutable,
  });

  const CopyWithFieldAnnotation.defaults() : this(immutable: false);

  @override
  final bool immutable;
}
