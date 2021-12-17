import 'package:copy_with_extension/copy_with_extension.dart';

part 'basic_class.g.dart';

@CopyWith()
class BasicClass {
  final String id;
  final String? optional;
  @CopyWithField(immutable: true)
  final int immutable;
  @CopyWithField(immutable: true)
  final int nullableImmutable;

  const BasicClass({
    required this.id,
    this.optional,
    required this.immutable,
    required this.nullableImmutable,
  });
}
