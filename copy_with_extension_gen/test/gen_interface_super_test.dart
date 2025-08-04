import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_interface_super_test.g.dart';

@CopyWith()
class Base {
  Base(this.a);
  final int a;
}

@CopyWith()
class Impl implements Base {
  Impl(this.a);

  @override
  final int a;
}

void main() {
  test('copyWith proxy should not extend interface proxies', () {
    final proxy = Impl(0).copyWith;
    expect(proxy, isNot(isA<_$BaseCWProxy>()));
  });
}
