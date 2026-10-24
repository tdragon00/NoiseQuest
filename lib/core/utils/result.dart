sealed class Result<T> {
  const Result();

  bool get isSuccess => this is Success<T>;

  T? get valueOrNull => switch (this) {
        Success<T>(:final value) => value,
        Failure<T>() => null,
      };

  String? get errorOrNull => switch (this) {
        Success<T>() => null,
        Failure<T>(:final message) => message,
      };
}

class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

class Failure<T> extends Result<T> {
  const Failure(this.message, {this.code, this.field, this.statusCode});

  final String message;
  final String? code;
  final String? field;
  final int? statusCode;

  bool get isUnauthorized => statusCode == 401;
  bool get isNetwork => statusCode == null;
}
