import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_multi_level_parameter_rename_test.g.dart';

@CopyWith()
class Base {
  const Base(this.a);
  final int a;
}

class MidPositional extends Base {
  // ignore: use_super_parameters
  const MidPositional(int b) : super(b);
}

@CopyWith()
class LeafPositional extends MidPositional {
  // ignore: use_super_parameters
  const LeafPositional(int c) : super(c);
}

class MidNamed extends Base {
  const MidNamed({required int renamed}) : super(renamed);
}

@CopyWith()
class LeafNamed extends MidNamed {
  const LeafNamed({required int d}) : super(renamed: d);
}

void main() {
  test('LeafPositional exposes inherited field', () {
    final leaf = LeafPositional(1);
    final copy = leaf.copyWith.a(2);
    expect(copy.a, 2);
  });

  test('LeafNamed exposes inherited field', () {
    final leaf = LeafNamed(d: 1);
    final copy = leaf.copyWith.a(2);
    expect(copy.a, 2);
  });
}
