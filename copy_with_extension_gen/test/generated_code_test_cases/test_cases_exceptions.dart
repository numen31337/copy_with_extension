part of 'source_gen_entrypoint.dart';

@ShouldThrow(
  'The @CopyWith annotation is only supported on classes. "Object wrongAnnotation" is not a class.',
)
// ignore: invalid_annotation_target
@CopyWith()
Object wrongAnnotation = Object();

@ShouldThrow(
  'The unnamed constructor of class NoConstructor has no parameters. copyWith generation requires at least one constructor parameter.',
)
@CopyWith()
class NoConstructor {
  int? test;
}

@ShouldThrow(
  'The constructor "empty" of class NoParamNamedConstructor has no parameters. copyWith generation requires at least one constructor parameter.',
)
@CopyWith(constructor: 'empty')
class NoParamNamedConstructor {
  NoParamNamedConstructor.empty();
}

@ShouldThrow(
    'Could not find a constructor named "test" in class WrongConstructor.')
@CopyWith(constructor: "test")
class WrongConstructor {}

@ShouldThrow(
    'Class NoDefaultConstructor must define an unnamed constructor to enable copyWith generation.')
@CopyWith()
class NoDefaultConstructor {
  NoDefaultConstructor.nonDefault();
}

@ShouldThrow(
  'Constructor parameter "nullableWithNonNullableConstructor" is non-nullable, but the corresponding class field is nullable. Make both nullable or both non-nullable.',
)
@CopyWith()
class TestNullability {
  TestNullability(
    int this.nullableWithNonNullableConstructor,
  );

  // Some info on this: https://github.com/numen31337/copy_with_extension/pull/69
  // If a field is nullable, you can change the type of the constructor parameter to be non-nullable. However, if you do this, an exception may be thrown because the constructor only accepts non-nullable parameters. The issue is that we cannot guarantee that the parameter will be non-null when calling the constructor in the `copyWith` function. Therefore, even if the constructor constructs an object with a nullable field, it is currently impossible to achieve this in the implementation.
  final int? nullableWithNonNullableConstructor;
}
