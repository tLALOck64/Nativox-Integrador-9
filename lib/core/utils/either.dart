// ============================================

import 'package:integrador/core/error/failure.dart';

/// Represents a value that can be either a Left (error/failure) or Right (success)
/// Similar to Result<Success, Error> in Kotlin or Either in functional programming
abstract class Either<L, R> {
  const Either();
  
  /// Returns true if this is a Left value (error/failure)
  bool get isLeft;
  
  /// Returns true if this is a Right value (success)
  bool get isRight;
  
  /// Gets the Left value. Throws StateError if this is a Right.
  L get left;
  
  /// Gets the Right value. Throws StateError if this is a Left.
  R get right;
  
  /// Folds this Either by applying leftFn if Left, rightFn if Right
  /// This is the primary way to handle Either values
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn);
  
  /// Maps the Right value to a new type, leaves Left unchanged
  Either<L, T> map<T>(T Function(R right) mapper);
  
  /// Maps the Left value to a new type, leaves Right unchanged
  Either<T, R> mapLeft<T>(T Function(L left) mapper);
  
  /// FlatMaps the Right value, leaves Left unchanged
  /// Useful for chaining operations that return Either
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper);
  
  /// Returns the Right value or the provided default
  R getOrElse(R Function() defaultValue);
  
  /// Returns this Either if Right, otherwise returns the alternative
  Either<L, R> orElse(Either<L, R> Function() alternative);
  
  @override
  bool operator ==(Object other);
  
  @override
  int get hashCode;
  
  @override
  String toString();
}

/// Represents a Left value (typically an error or failure)
class Left<L, R> extends Either<L, R> {
  final L _value;
  
  const Left(this._value);
  
  @override
  bool get isLeft => true;
  
  @override
  bool get isRight => false;
  
  @override
  L get left => _value;
  
  @override
  R get right => throw StateError('Attempted to get right value from Left($_value)');
  
  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return leftFn(_value);
  }
  
  @override
  Either<L, T> map<T>(T Function(R right) mapper) {
    return Left<L, T>(_value);
  }
  
  @override
  Either<T, R> mapLeft<T>(T Function(L left) mapper) {
    return Left<T, R>(mapper(_value));
  }
  
  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper) {
    return Left<L, T>(_value);
  }
  
  @override
  R getOrElse(R Function() defaultValue) {
    return defaultValue();
  }
  
  @override
  Either<L, R> orElse(Either<L, R> Function() alternative) {
    return alternative();
  }
  
  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
           (other is Left<L, R> && other._value == _value);
  }
  
  @override
  int get hashCode => _value.hashCode;
  
  @override
  String toString() => 'Left($_value)';
}

/// Represents a Right value (typically a success value)
class Right<L, R> extends Either<L, R> {
  final R _value;
  
  const Right(this._value);
  
  @override
  bool get isLeft => false;
  
  @override
  bool get isRight => true;
  
  @override
  L get left => throw StateError('Attempted to get left value from Right($_value)');
  
  @override
  R get right => _value;
  
  @override
  T fold<T>(T Function(L left) leftFn, T Function(R right) rightFn) {
    return rightFn(_value);
  }
  
  @override
  Either<L, T> map<T>(T Function(R right) mapper) {
    return Right<L, T>(mapper(_value));
  }
  
  @override
  Either<T, R> mapLeft<T>(T Function(L left) mapper) {
    return Right<T, R>(_value);
  }
  
  @override
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) mapper) {
    return mapper(_value);
  }
  
  @override
  R getOrElse(R Function() defaultValue) {
    return _value;
  }
  
  @override
  Either<L, R> orElse(Either<L, R> Function() alternative) {
    return this;
  }
  
  @override
  bool operator ==(Object other) {
    return identical(this, other) || 
           (other is Right<L, R> && other._value == _value);
  }
  
  @override
  int get hashCode => _value.hashCode;
  
  @override
  String toString() => 'Right($_value)';
}

// ============================================
// EXTENSIONES ÚTILES PARA EITHER
// ============================================

extension EitherExtensions<L, R> on Either<L, R> {
  /// Converts Either to nullable, returns null if Left
  /// Useful when you want to ignore errors and just get the value or null
  R? toNullable() => isRight ? right : null;
  
  /// Converts Either to a Future
  /// Useful for async operations
  Future<Either<L, R>> toFuture() => Future.value(this);
  
  /// Swaps Left and Right types
  /// Useful in some functional programming scenarios
  Either<R, L> swap() => fold((l) => Right(l), (r) => Left(r));
  
  /// Applies a side effect if Right, returns original Either
  /// Useful for logging, analytics, etc.
  Either<L, R> onRight(void Function(R value) sideEffect) {
    if (isRight) sideEffect(right);
    return this;
  }
  
  /// Applies a side effect if Left, returns original Either
  /// Useful for error logging, analytics, etc.
  Either<L, R> onLeft(void Function(L value) sideEffect) {
    if (isLeft) sideEffect(left);
    return this;
  }
  
  /// Applies a side effect regardless of Left or Right
  /// Useful for cleanup operations
  Either<L, R> onBoth({
    void Function(L left)? onLeft,
    void Function(R right)? onRight,
  }) {
    if (isLeft && onLeft != null) onLeft(left);
    if (isRight && onRight != null) onRight(right);
    return this;
  }
  
  /// Converts to a List containing the Right value or empty if Left
  List<R> toList() => isRight ? [right] : [];
  
  /// Filters the Right value, converting to Left if predicate fails
  Either<L, R> filter(bool Function(R value) predicate, L Function() onFalse) {
    if (isRight && !predicate(right)) {
      return Left(onFalse());
    }
    return this;
  }
}

// ============================================
// EXTENSIONES PARA FUTURE<EITHER>
// ============================================

extension FutureEitherExtensions<L, R> on Future<Either<L, R>> {
  /// Maps the Right value of a Future<Either> asynchronously
  Future<Either<L, T>> mapAsync<T>(Future<T> Function(R value) mapper) async {
    final either = await this;
    if (either.isLeft) return Left(either.left);
    try {
      final result = await mapper(either.right);
      return Right(result);
    } catch (e) {
      // Re-throw the exception to be handled by the caller
      rethrow;
    }
  }
  
  /// FlatMaps the Right value of a Future<Either> asynchronously
  Future<Either<L, T>> flatMapAsync<T>(
    Future<Either<L, T>> Function(R value) mapper,
  ) async {
    final either = await this;
    if (either.isLeft) return Left(either.left);
    return await mapper(either.right);
  }
  
  /// Applies side effects to Future<Either>
  Future<Either<L, R>> onEither({
    void Function(L left)? onLeft,
    void Function(R right)? onRight,
  }) async {
    final either = await this;
    return either.onBoth(onLeft: onLeft, onRight: onRight);
  }
}

// ============================================
// UTILIDADES PARA CREAR EITHER
// ============================================

class EitherUtils {
  /// Creates a Right value
  static Either<L, R> right<L, R>(R value) => Right(value);
  
  /// Creates a Left value
  static Either<L, R> left<L, R>(L value) => Left(value);
  
  /// Wraps a function call in Either, catching exceptions
  /// Perfect for your repository implementations
  static Either<Exception, T> tryCatch<T>(T Function() fn) {
    try {
      return Right(fn());
    } catch (e) {
      return Left(e is Exception ? e : Exception(e.toString()));
    }
  }
  
  /// Wraps an async function call in Either, catching exceptions
  /// Perfect for your async repository calls
  static Future<Either<Exception, T>> tryCatchAsync<T>(
    Future<T> Function() fn,
  ) async {
    try {
      final result = await fn();
      return Right(result);
    } catch (e) {
      return Left(e is Exception ? e : Exception(e.toString()));
    }
  }
  
  /// Combines multiple Either values into one
  /// Useful when you need all operations to succeed
  static Either<L, List<R>> sequence<L, R>(List<Either<L, R>> eithers) {
    final results = <R>[];
    for (final either in eithers) {
      if (either.isLeft) return Left(either.left);
      results.add(either.right);
    }
    return Right(results);
  }
  
  /// Maps over a list and collects the results in Either
  /// Stops at the first Left encountered
  static Either<L, List<T>> traverse<L, R, T>(
    List<R> list,
    Either<L, T> Function(R item) mapper,
  ) {
    return sequence(list.map(mapper).toList());
  }
  
  /// Runs multiple Either operations in parallel and combines results
  /// Useful for your ProfileViewModel.loadProfile() method
  static Future<Either<L, List<R>>> parallel<L, R>(
    List<Future<Either<L, R>>> futures,
  ) async {
    final results = await Future.wait(futures);
    return sequence(results);
  }
  
  /// Creates an Either from a nullable value
  static Either<L, R> fromNullable<L, R>(R? value, L Function() onNull) {
    return value != null ? Right(value) : Left(onNull());
  }
  
  /// Creates an Either from a boolean condition
  static Either<L, R> fromCondition<L, R>(
    bool condition,
    R Function() onTrue,
    L Function() onFalse,
  ) {
    return condition ? Right(onTrue()) : Left(onFalse());
  }
}

typedef AuthResult<T> = Either<Failure, T>;
typedef ProfileResult<T> = Either<Failure, T>;
typedef NetworkResult<T> = Either<Failure, T>;

/// Extension specifically for Failure types (your Left values)
extension FailureExtensions on Failure {
  /// Converts any Failure to a Left Either
  Left<Failure, T> toLeft<T>() => Left<Failure, T>(this);
  
  /// Checks if this is a network-related failure
  bool get isNetworkFailure => this is NetworkFailure;
  
  /// Checks if this is an auth-related failure
  bool get isAuthFailure => this is AuthFailure;
  
  /// Checks if this is a validation failure
  bool get isValidationFailure => this is ValidationFailure;
  
  /// Gets a user-friendly message for UI display
  String get userMessage {
    if (this is NetworkFailure) {
      return 'Problema de conexión. Verifica tu internet.';
    } else if (this is AuthFailure) {
      return message;
    } else if (this is ValidationFailure) {
      return message;
    } else if (this is ServerFailure) {
      return 'Error del servidor. Intenta más tarde.';
    } else {
      return 'Error inesperado. Intenta nuevamente.';
    }
  }
}

/// Success value extensions
extension SuccessExtensions<T> on T {
  /// Converts any value to a Right Either
  Right<L, T> toRight<L>() => Right<L, T>(this);
}

// ============================================
// MATCHER PATTERN (OPCIONAL)
// ============================================

/// Pattern matching utility for Either (similar to Kotlin's when)
class EitherMatcher<L, R, T> {
  final Either<L, R> _either;
  T? _result;
  
  EitherMatcher(this._either);
  
  EitherMatcher<L, R, T> onLeft(T Function(L left) handler) {
    if (_either.isLeft && _result == null) {
      _result = handler(_either.left);
    }
    return this;
  }
  
  EitherMatcher<L, R, T> onRight(T Function(R right) handler) {
    if (_either.isRight && _result == null) {
      _result = handler(_either.right);
    }
    return this;
  }
  
  T orElse(T Function() defaultHandler) {
    return _result ?? defaultHandler();
  }
}

extension EitherMatcherExtension<L, R> on Either<L, R> {
  EitherMatcher<L, R, T> match<T>() => EitherMatcher<L, R, T>(this);
}
