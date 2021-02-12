class GoblException {
  final String message;
  final Map<String, dynamic> data;

  GoblException({this.message, this.data = const {}});

  Map<String, dynamic> toJson() {
    return {'message': message, 'data': data};
  }
}
