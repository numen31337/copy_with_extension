import 'package:copy_with_extension/copy_with_extension.dart';

part 'immutable_test_case.g.dart';

@CopyWith(generateCopyWithNull: true)
class TestCaseClass<T extends String> {
  final T id;
  @CopyWithField(immutable: true)
  final int immutableField;

  TestCaseClass({required this.id, required this.immutableField});
}
