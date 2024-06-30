import 'package:uuid/uuid.dart';

class NpshPoint {
  final num npsh3;
  final num q;
  late String _id;

  String get id => _id;

  NpshPoint({
    required this.npsh3,
    required this.q,
  }) {
    _id = const Uuid().v4();
  }

  NpshPoint.fromJson(Map<String, dynamic> json)
      : npsh3 = json['npsh3'] as num,
        q = json['q'] as num,
        _id = json['_id'];

  Map<String, dynamic> toJson() =>
      {'npsh3': npsh3.toDouble(), 'q': q.toDouble(), '_id': _id};
}
