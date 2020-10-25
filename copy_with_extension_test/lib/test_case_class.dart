import 'package:copy_with_extension/copy_with_extension.dart';

part 'test_case_class.g.dart';

@CopyWith(generateCopyWithNull: true)
class TestCaseClass<T extends String> {
  final T id;
  @CopyWithField(immutable: true)
  final int immutableField;

  TestCaseClass({this.id, this.immutableField});
}
