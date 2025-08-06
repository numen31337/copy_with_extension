import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

import 'helpers/test_utils.dart';

part 'gen_type_alias_test.g.dart';

typedef MyInt = int;
typedef MyList<T> = List<T>;
typedef DeepTypeDef<T> = MyList<MyList<MyInt>>; // ignore: unused_type_parameter

@CopyWith()
class AliasField {
  const AliasField({
    required this.value,
    required this.list,
    required this.deep,
    required this.nested,
  });

  final MyInt value;
  final MyList<int> list;
  final DeepTypeDef<String> deep;
  final MyList<MyList<MyInt>> nested;
}

@CopyWith()
class RealBase {
  const RealBase({required this.a});

  final int a;
}

typedef BaseAlias = RealBase;

@CopyWith()
class SubViaAlias extends BaseAlias {
  const SubViaAlias({required super.a, this.b});

  final String? b;
}

void main() {
  test('generated code preserves type alias names', () async {
    final output = await readGeneratedFile('gen_type_alias_test.g.dart');
    expect(output, contains('MyInt'));
    expect(output, contains('MyList<int>'));
    expect(output, contains('DeepTypeDef'));
    expect(output, contains('MyList<MyList<MyInt>>'));
  });

  test('copyWith recognizes annotated superclass referenced via typedef', () {
    final result = SubViaAlias(a: 1, b: 'x').copyWith(a: 2);
    expect(result, isA<SubViaAlias>());
    expect(result.a, 2);
    expect(result.b, 'x');
  });

  test('field proxy works with superclass typedef', () {
    final result = SubViaAlias(a: 1, b: 'x').copyWith.a(3);
    expect(result, isA<SubViaAlias>());
    expect(result.a, 3);
    expect(result.b, 'x');
  });
}
