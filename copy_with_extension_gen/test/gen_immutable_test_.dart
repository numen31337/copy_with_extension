import 'package:copy_with_extension/copy_with_extension.dart';

//Won't work without it!
part 'gen_immutable_test_.g.dart';

@CopyWith(copyWith: true, copyWithNull: true)
class TestCaseClass<T extends String> {
  final T id;
  @CopyWithField(immutable: true)
  final int immutableField;

  TestCaseClass({required this.id, required this.immutableField});
}
