import 'package:uuid/uuid.dart';

class Point {
  final num porcentajeApertura;
  late num qInicial;
  late num presionEntrada;
  late num presionSalida;
  late num densidad;

  late String _id;
  late num _hNeta;

  String get id => _id;
  num get hNeta => _hNeta;

  Point(
      {required this.porcentajeApertura,
      required this.qInicial,
      required this.presionEntrada,
      required this.presionSalida,
      required this.densidad}) {
    _id = const Uuid().v4();
    _hNeta = calcularHneta();
  }

  Point.fromJson(Map<String, dynamic> json)
      : porcentajeApertura = json['porcentajeApertura'] as num,
        qInicial = json['qInicial'] as num,
        presionEntrada = json['presionEntrada'] as num,
        presionSalida = json['presionSalida'] as num,
        densidad = json['densidad'] as num,
        _hNeta = json['_hNeta'] as num,
        _id = json['_id'] as String;

  Map<String, dynamic> toJson() => {
        'porcentajeApertura': porcentajeApertura.toDouble(),
        'qInicial': qInicial.toDouble(),
        'presionEntrada': presionEntrada.toDouble(),
        'presionSalida': presionSalida.toDouble(),
        'densidad': densidad.toDouble(),
        '_hNeta': _hNeta.toDouble(),
        '_id': _id
      };

  num calcularHneta() =>
      (presionSalida * 1000 / (9.81 * densidad)) +
      (presionEntrada.abs() * 1000 / (9.81 * densidad));
}
