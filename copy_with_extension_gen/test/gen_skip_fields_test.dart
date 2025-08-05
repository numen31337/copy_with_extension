import 'package:copy_with_extension/copy_with_extension.dart';
import 'package:test/test.dart';

part 'gen_skip_fields_test.g.dart';

@CopyWith(skipFields: true)
class SkipFieldsClass {
  const SkipFieldsClass({required this.id, this.optional});

  final int id;
  final String? optional;
}

void main() {
  test('Call method works when skipFields is true', () {
    final result = const SkipFieldsClass(
      id: 1,
      optional: 'foo',
    ).copyWith(id: 2, optional: 'bar');

    expect(result.id, 2);
    expect(result.optional, 'bar');
  });

  test('Field specific methods are not generated', () {
    final dynamic proxy = const SkipFieldsClass(
      id: 1,
      optional: 'foo',
    ).copyWith;
    expect(() => proxy.id(2), throwsNoSuchMethodError);
  });
}
