import 'dart:typed_data' as td;

import 'package:copy_with_extension/copy_with_extension.dart';

part 'gen_namespace_test.g.dart';

class ByteBuffer {}

@CopyWith()
class NamespaceTestClass {
  final td.ByteBuffer namespacedProperty;
  final ByteBuffer regularProperty;

  NamespaceTestClass({
    required this.namespacedProperty,
    required this.regularProperty,
  });
}
