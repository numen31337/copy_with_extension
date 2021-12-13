import 'package:meta/meta.dart' show immutable;
import 'package:copy_with_extension/copy_with_extension.dart';

//Won't work without it!
part 'basic_test_case.g.dart';

@immutable
@CopyWith(generateCopyWithNull: true)
class BasicClass {
  final String id;
  final String? optional;

  const BasicClass({required this.id, this.optional});
}

@immutable
@CopyWith(generateCopyWithNull: true)
class BasicClassOnlyNonNullable {
  final String id;
  final String nextID;

  const BasicClassOnlyNonNullable({required this.id, required this.nextID});
}

@immutable
@CopyWith(namedConstructor: "_")
class BasicClassNamed {
  final String id;
  final String? optional;

  const BasicClassNamed._({required this.id, this.optional});
}

@immutable
@CopyWith(namedConstructor: "test", generateCopyWithNull: true)
class BasicClassNamed1 {
  final String id;
  final String? optional;

  const BasicClassNamed1.test({required this.id, this.optional});
}
