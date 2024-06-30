import 'package:uuid/uuid.dart';

class ObservationPoint {
  final num porcentajeAperturaVs;
  late num qInicial;
  late num hTeorico;
  late num presionEntrada;
  late num presionSalida;
  late num densidad;

  late String _id;
  late num _hExperimental;
  late num _deltaH;

  String get id => _id;
  num get hExperimental => _hExperimental;
  num get deltaH => _deltaH;

  ObservationPoint(
      {required this.porcentajeAperturaVs,
      required this.qInicial,
      required this.hTeorico,
      required this.presionEntrada,
      required this.presionSalida,
      required this.densidad}) {
    _id = const Uuid().v4();
    _hExperimental = calcularHneta();
    _deltaH = deltaHPercentage();
  }

  ObservationPoint.fromJson(Map<String, dynamic> json)
      : porcentajeAperturaVs = json['porcentajeAperturaVs'] as num,
        qInicial = json['qInicial'] as num,
        hTeorico = json['hTeorico'] as num,
        presionEntrada = json['presionEntrada'] as num,
        presionSalida = json['presionSalida'] as num,
        densidad = json['densidad'] as num,
        _id = json['_id'] as String,
        _hExperimental = json['_hExperimental'] as num,
        _deltaH = json['_deltaH'] as num;

  Map<String, dynamic> toJson() => {
        'porcentajeAperturaVs': porcentajeAperturaVs.toDouble(),
        'qInicial': qInicial.toDouble(),
        'hTeorico': hTeorico.toDouble(),
        'presionEntrada': presionEntrada.toDouble(),
        'presionSalida': presionSalida.toDouble(),
        'densidad': densidad.toDouble(),
        '_id': _id,
        '_hExperimental': _hExperimental.toDouble(),
        '_deltaH': _deltaH.toDouble(),
      };

  num deltaHPercentage() => presionEntrada != 0 || presionSalida != 0
      ? (((hTeorico - _hExperimental) / hTeorico) * 100)
      : 0;

  num calcularHneta() =>
      (presionSalida * 1000 / (9.81 * densidad)) +
      (presionEntrada.abs() * 1000 / (9.81 * densidad));

  updatePresionEntrada(num newPresionEntrada) {
    presionEntrada = newPresionEntrada;
    _hExperimental = calcularHneta();
    _deltaH = deltaHPercentage();
  }

  updatePresionSalida(num newPresionSalida) {
    presionSalida = newPresionSalida;
    _hExperimental = calcularHneta();
    _deltaH = deltaHPercentage();
  }

  updateQ(num newQ, num newHTeorico) {
    qInicial = newQ;
    hTeorico = newHTeorico;
  }
}
