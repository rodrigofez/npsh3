import 'package:equations/equations.dart';
import 'package:npsh3/models/npsh_point.dart';
import 'package:npsh3/models/observation_point.dart';
import 'package:npsh3/models/point.dart';
import 'package:uuid/uuid.dart';

class Ensayo {
  final List<num> percentages = [
    100,
    95,
    90,
    85,
    80,
    75,
    70,
    65,
    60,
    55,
    50,
    45,
    40,
    35,
    30,
    25
  ];
  late String _id;
  late List<Point> _points = [];
  late List<List<ObservationPoint>> _observationPoints = [[], [], [], [], []];
  late List<NpshPoint> _npshPoints = [];

  String _marca = '';
  String _serie = '';
  num _potencia = 0;
  num _densidad = 1050;
  num _pVapor = 3.173;
  num _temperatura = 25;

  num get densidad => _densidad;
  num get pvapor => _pVapor;
  num get temperatura => _temperatura;
  String get id => _id;

  Ensayo() {
    _id = const Uuid().v4();
    initializePoints();
  }

  List<Point> get allPoints => _points;
  List<List<ObservationPoint>> get allObservationPoints => _observationPoints;
  List<NpshPoint> get allNpshPoints => _npshPoints;
  String get marca => _marca;
  String get serie => _serie;
  num get potencia => _potencia;

  void initializePoints() {
    _points = percentages
        .map((percentage) => Point(
              porcentajeApertura: percentage,
              presionEntrada: 0,
              presionSalida: 0,
              qInicial: 0,
              densidad: _densidad,
            ))
        .toList();

    _npshPoints = [
      ...[1, 2, 3, 4, 5].map((index) => NpshPoint(npsh3: 0, q: 0))
    ];

    _observationPoints = [
      [
        ...percentages
            .map((percentage) => ObservationPoint(
                porcentajeAperturaVs: percentage,
                presionEntrada: 0,
                presionSalida: 0,
                qInicial: 0,
                hTeorico: 0,
                densidad: _densidad))
            .toList()
      ],
      [
        ...percentages
            .map((percentage) => ObservationPoint(
                porcentajeAperturaVs: percentage,
                presionEntrada: 0,
                presionSalida: 0,
                qInicial: 0,
                hTeorico: 0,
                densidad: _densidad))
            .toList()
      ],
      [
        ...percentages
            .map((percentage) => ObservationPoint(
                porcentajeAperturaVs: percentage,
                presionEntrada: 0,
                presionSalida: 0,
                qInicial: 0,
                hTeorico: 0,
                densidad: _densidad))
            .toList()
      ],
      [
        ...percentages
            .map((percentage) => ObservationPoint(
                porcentajeAperturaVs: percentage,
                presionEntrada: 0,
                presionSalida: 0,
                qInicial: 0,
                hTeorico: 0,
                densidad: _densidad))
            .toList()
      ],
      [
        ...percentages
            .map((percentage) => ObservationPoint(
                porcentajeAperturaVs: percentage,
                presionEntrada: 0,
                presionSalida: 0,
                qInicial: 0,
                hTeorico: 0,
                densidad: _densidad))
            .toList()
      ],
    ];
  }

  void updateDensidad({required num newDensidad}) {
    _densidad = newDensidad;

    _points = _points
        .map((point) => Point(
            porcentajeApertura: point.porcentajeApertura,
            presionEntrada: point.presionEntrada,
            presionSalida: point.presionSalida,
            qInicial: point.qInicial,
            densidad: newDensidad))
        .toList();

    _observationPoints = _observationPoints
        .map((observationPoint) => observationPoint
            .map((e) => ObservationPoint(
                porcentajeAperturaVs: e.porcentajeAperturaVs,
                qInicial: e.qInicial,
                hTeorico: e.hTeorico,
                presionEntrada: e.presionEntrada,
                presionSalida: e.presionSalida,
                densidad: newDensidad))
            .toList())
        .toList();
  }

  void updatePVapor({required num newPVapor}) {
    _pVapor = newPVapor;
  }

  void calcularPvapor({required num temperatura}) {
    const linearInter = SplineInterpolation(nodes: [
      InterpolationNode(x: 6.97, y: 1.0),
      InterpolationNode(x: 13.02, y: 1.5),
      InterpolationNode(x: 17.50, y: 2.0),
      InterpolationNode(x: 21.08, y: 2.5),
      InterpolationNode(x: 24.08, y: 3.0),
      InterpolationNode(x: 28.96, y: 4.0),
      InterpolationNode(x: 32.87, y: 5.0),
      InterpolationNode(x: 40.29, y: 7.5),
      InterpolationNode(x: 45.81, y: 10.0),
      InterpolationNode(x: 53.97, y: 15)
    ]);

    final newPvapor = linearInter.compute(temperatura.toDouble());

    updatePVapor(newPVapor: newPvapor);
  }

  void updateTemperatura({required num newTemperatura}) {
    _temperatura = newTemperatura;
    calcularPvapor(temperatura: newTemperatura);
  }

  void updatePresionEntrada(
      {required String id, required num newPresionEntrada}) {
    int pointIndex = _points.indexWhere((point) => point.id == id);
    if (pointIndex == -1) return;

    Point pointToEdit = _points[pointIndex];

    print(pointToEdit.toJson());

    _points[pointIndex] = Point(
        porcentajeApertura: pointToEdit.porcentajeApertura,
        qInicial: pointToEdit.qInicial,
        presionEntrada: newPresionEntrada,
        presionSalida: pointToEdit.presionSalida,
        densidad: _densidad);
  }

  void updateQ({required String id, required num newQ}) {
    int pointIndex = _points.indexWhere((point) => point.id == id);
    if (pointIndex == -1) return;

    Point pointToEdit = _points[pointIndex];

    _points[pointIndex] = Point(
        porcentajeApertura: pointToEdit.porcentajeApertura,
        qInicial: newQ,
        presionEntrada: pointToEdit.presionEntrada,
        presionSalida: pointToEdit.presionSalida,
        densidad: _densidad);
  }

  void updatePresionSalida(
      {required String id, required num newPresionSalida}) {
    int pointIndex = _points.indexWhere((point) => point.id == id);
    if (pointIndex == -1) return;

    Point pointToEdit = _points[pointIndex];

    _points[pointIndex] = Point(
        porcentajeApertura: pointToEdit.porcentajeApertura,
        qInicial: pointToEdit.qInicial,
        presionSalida: newPresionSalida,
        presionEntrada: pointToEdit.presionEntrada,
        densidad: _densidad);
  }

  // interpolacion para encontrar H teorico para el caudal dado
  num interpolate({required num q}) {
    _points.sort((b, a) => a.qInicial.compareTo(b.qInicial));

    final spline = SplineInterpolation(nodes: [
      ..._points
          .takeWhile((value) {
            return value.qInicial != 0;
          })
          .toList()
          .reversed
          .map((point) => InterpolationNode(
              x: point.qInicial.toDouble(), y: point.hNeta.toDouble())),
    ]);

    final newVal = spline.compute(q.toDouble());

    return newVal;
  }

  //
  // num interpolate3({required num q}) {
  //   _points.sort((b, a) => a.qInicial.compareTo(b.qInicial));

  //   final spline = SplineInterpolation(nodes: [
  //     ..._points
  //         .takeWhile((value) {
  //           return value.qInicial != 0;
  //         })
  //         .toList()
  //         .reversed
  //         .map((point) => InterpolationNode(
  //             x: point.qInicial.toDouble() * 0.97,
  //             y: point.hNeta.toDouble() * 0.97)),
  //   ]);

  //   final newVal = spline.compute(q.toDouble());

  //   return newVal;
  // }

  void updateMarca({required String newMarca}) {
    _marca = newMarca;
  }

  void updateSerie({required String newSerie}) {
    _serie = newSerie;
  }

  void updatePotencia({required num newPotencia}) {
    _potencia = newPotencia;
  }

  bool get isReady => _points.every((point) => true);

  void updateQObservationPoint(
      {required String id, required int index, required num newQ}) {
    int pointIndex =
        _observationPoints[index].indexWhere((point) => point.id == id);
    if (pointIndex == -1) return;

    ObservationPoint pointToEdit = _observationPoints[index][pointIndex];

    pointToEdit.updateQ(newQ, interpolate(q: newQ));
  }

  void updatePresionEntradaObservationPoint(
      {required String id, required int index, required num pEntrada}) {
    int pointIndex =
        _observationPoints[index].indexWhere((point) => point.id == id);
    if (pointIndex == -1) return;

    ObservationPoint pointToEdit = _observationPoints[index][pointIndex];

    pointToEdit.updatePresionEntrada(pEntrada);
  }

  void updatePresionSalidaObservationPoint(
      {required String id, required int index, required num pSalida}) {
    int pointIndex =
        _observationPoints[index].indexWhere((point) => point.id == id);
    if (pointIndex == -1) return;

    ObservationPoint pointToEdit = _observationPoints[index][pointIndex];

    pointToEdit.updatePresionSalida(pSalida);
  }

  // observations points

  void setObservationPointQ({required int index, required num newQ}) {
    Point selectedPoint = _points.firstWhere((point) => point.qInicial == newQ);

    _observationPoints[index][0] = ObservationPoint(
        qInicial: selectedPoint.qInicial,
        porcentajeAperturaVs: percentages[0],
        hTeorico: selectedPoint.hNeta,
        presionEntrada: selectedPoint.presionEntrada,
        presionSalida: selectedPoint.presionSalida,
        densidad: _densidad);
  }

  bool observationPointDeltaGreaterThan3({required int index}) {
    return _observationPoints[index].any((point) => point.deltaH >= 3);
  }

  bool isTestComplete() {
    return _observationPoints.every((observationPoint) =>
        observationPoint.any((point) => point.deltaH >= 3));
  }

  void generateNPSH3() {
    _observationPoints.asMap().forEach((index, oPoint) {
      List<ObservationPoint> observationPoint = oPoint
          .where((point) =>
              point.qInicial != 0 &&
              point.presionEntrada != 0 &&
              point.presionSalida != 0)
          .toList();

      observationPoint.sort((b, a) => a.deltaH.compareTo(b.deltaH));

      final qSpline = SplineInterpolation(nodes: [
        ...observationPoint.reversed.map((point) => InterpolationNode(
            x: point.deltaH.toDouble(), y: point.qInicial.toDouble())),
      ]);

      final pESpline = SplineInterpolation(nodes: [
        ...observationPoint.reversed.map((point) => InterpolationNode(
            x: point.deltaH.toDouble(), y: point.presionEntrada.toDouble())),
      ]);

      final pe3 = pESpline.compute(3);
      final q3 = qSpline.compute(3);

      final npsh3 =
          ((((101.325 - pe3) - pvapor) * 1000) / (9.81 * densidad)).abs();

      _npshPoints[index] = NpshPoint(npsh3: npsh3, q: q3);
    });
  }

  Map<String, dynamic> toJson() => {
        '_id': _id,
        '_points': _points.map((point) => point.toJson()).toList(),
        '_observationPoints': _observationPoints
            .map((step) => step.map((point) => point.toJson()).toList())
            .toList(),
        '_npshPoints': _npshPoints.map((point) => point.toJson()).toList(),
        '_marca': _marca,
        '_serie': _serie,
        '_densidad': _densidad.toDouble(),
        '_pVapor': _pVapor.toDouble(),
        '_temperatura': _temperatura.toDouble(),
        '_potencia': _potencia.toDouble(),
      };

  Ensayo.fromJson(Map<String, dynamic> json)
      : _id = json['_id'] as String,
        _points = (json['_points'] as List)
            .map((item) => Point.fromJson(item as Map<String, dynamic>))
            .toList(),
        _observationPoints = (json['_observationPoints'] as List)
            .map((step) => (step as List)
                .map((item) =>
                    ObservationPoint.fromJson(item as Map<String, dynamic>))
                .toList())
            .toList(),
        _npshPoints = (json['_npshPoints'] as List)
            .map((item) => NpshPoint.fromJson(item as Map<String, dynamic>))
            .toList(),
        _marca = json['_marca'] as String,
        _serie = json['_serie'] as String,
        _densidad = (json['_densidad'] as num).toDouble(),
        _pVapor = (json['_pVapor'] as num).toDouble(),
        _temperatura = (json['_temperatura'] as num).toDouble(),
        _potencia = (json['_potencia'] as num).toDouble();
}
