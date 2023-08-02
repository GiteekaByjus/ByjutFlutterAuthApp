class Error<T> {
  final T? data;
  final String message;

  const Error({
    required this.message,
    this.data,
  });
}
