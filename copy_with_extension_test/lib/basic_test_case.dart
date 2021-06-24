import 'package:meta/meta.dart' show immutable;
import 'package:copy_with_extension/copy_with_extension.dart';

//Won't work without it!
part 'basic_test_case.g.dart';

@immutable
@CopyWith(generateCopyWithNull: true)
class BasicClass {
  final String id;
  final String? optional;
  final List<String?> nullableGeneric;

  BasicClass({required this.id, this.optional, required this.nullableGeneric});
}

@immutable
@CopyWith(generateCopyWithNull: true)
class BasicClassOnlyNonNullable {
  final String id;
  final String nextID;

  BasicClassOnlyNonNullable({required this.id, required this.nextID});
}
