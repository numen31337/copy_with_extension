const String pkgName = "copy_with_extension_gen";

const String annotationsBase = r'''
class CopyWith {
  const CopyWith({this.generateCopyWithNull = false})
      : assert(generateCopyWithNull is bool);

  final bool generateCopyWithNull;
}
''';

const String correctInput = r'''
import 'package:copy_with_extension/copy_with_extension.dart';

part 'basic_class.g.dart';

@CopyWith(generateCopyWithNull: true)
class BasicClass<T extends String> {
  final T id;

  BasicClass({this.id});
}
''';

const String correctResult = r'''
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'basic_class.dart';

// **************************************************************************
// CopyWithGenerator
// **************************************************************************

extension BasicClassCopyWithExtension<T extends String> on BasicClass<T> {
  BasicClass<T> copyWith({
    T id,
  }) {
    return BasicClass<T>(
      id: id ?? this.id,
    );
  }

  BasicClass<T> copyWithNull({
    bool id = false,
  }) {
    return BasicClass<T>(
      id: id == true ? null : this.id,
    );
  }
}
''';
