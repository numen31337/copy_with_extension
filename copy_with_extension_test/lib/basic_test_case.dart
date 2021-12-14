import 'package:meta/meta.dart' show immutable;
import 'package:copy_with_extension/copy_with_extension.dart';

//Won't work without it!
part 'basic_test_case.g.dart';

@immutable
@CopyWith()
class BasicClass {
  final String id;
  final String? optional;

  const BasicClass({required this.id, this.optional});
}

@immutable
@CopyWith(copyWith: true, copyWithNull: true)
class BasicClassOnlyNonNullable {
  final String id;
  final String nextID;

  const BasicClassOnlyNonNullable({required this.id, required this.nextID});
}

@immutable
@CopyWith(namedConstructor: "_", copyWithValues: true)
class BasicClassNamed {
  final String id;
  final String? optional;

  const BasicClassNamed({this.optional}) : id = "";
  const BasicClassNamed._({required this.id, this.optional});
}

@immutable
@CopyWith(namedConstructor: "test")
class BasicClassNamedWithoutCopyWithAndCopyWithNull {
  final String id;
  final String? optional;

  const BasicClassNamedWithoutCopyWithAndCopyWithNull.test({
    required this.id,
    this.optional,
  });
}
