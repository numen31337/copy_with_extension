import 'package:copy_with_extension/copy_with_extension.dart';

part 'test_case_class.g.dart';

@CopyWith(generateCopyWithNull: true)
class Test_Case_Class<T extends String> {
  final T id;
  @CopyWithField(immutable: true)
  final int immutableField;

  Test_Case_Class({this.id, this.immutableField});
}
