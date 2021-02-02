import 'package:meta/meta.dart' show immutable;
import 'package:copy_with_extension/copy_with_extension.dart';

/// Make sure that `part` is specified, even before launching the builder
part 'example.g.dart';

@immutable
@CopyWith()
class SimpleObject {
  final String id;
  final int value;

  /// Make sure that constructor has named parameters (wrapped in curly braces)
  SimpleObject({required this.id, required this.value});
}
