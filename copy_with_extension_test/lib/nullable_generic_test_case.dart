import 'package:meta/meta.dart' show immutable;
import 'package:copy_with_extension/copy_with_extension.dart';

//Won't work without it!
part 'nullable_generic_test_case.g.dart';

@immutable
@CopyWith(generateCopyWithNull: true)
class NullableGenericTestCase {
  final List<String?> nullableGeneric;
  final List<List<List<int?>?>>? deepNestedGeneric;

  NullableGenericTestCase({
    this.deepNestedGeneric,
    required this.nullableGeneric,
  });
}
