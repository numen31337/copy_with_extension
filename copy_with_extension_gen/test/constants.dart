const String pkgName = "copy_with_extension_gen";

const String annotationsBase = r'''
class CopyWith {
  const CopyWith();
}
''';

const String correctInput = r'''
import 'package:copy_with_extension/copy_with_extension.dart';

part 'basic_class.g.dart';

@CopyWith()
class BasicClass {
  final String id;

  BasicClass({this.id});
}
''';

const String correctResult = r'''
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_class.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

// ignore_for_file: argument_type_not_assignable, implicit_dynamic_type, always_specify_types

extension BasicClassCopyWithExtension on BasicClass {
  BasicClass copyWith({
    String id,
  }) {
    return BasicClass(
      id: id ?? this.id,
    );
  }
}
''';
