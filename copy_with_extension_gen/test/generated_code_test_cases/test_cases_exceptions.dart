part of 'source_gen_entrypoint.dart';

@ShouldThrow(
  'Only classes can be annotated with "CopyWith". "Object wrongAnnotation" is not a ClassElement.',
)
// ignore: invalid_annotation_target
@CopyWith()
Object wrongAnnotation = Object();

@ShouldThrow(
  'Unnamed constructor for NoConstructor has no parameters or missing.',
)
@CopyWith()
class NoConstructor {
  int? test;
}

@ShouldThrow('Named Constructor "test" constructor is missing.')
@CopyWith(constructor: "test")
class WrongConstructor {}

@ShouldThrow('Default constructor for "NoDefaultConstructor" is missing.')
@CopyWith()
class NoDefaultConstructor {
  NoDefaultConstructor.nonDefault();
}

@ShouldThrow(
  'The nullability of the constructor parameter "nullableWithNonNullableConstructor" does not match the nullability of the corresponding field in the object.',
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
