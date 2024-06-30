import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:npsh3/models/npsh_point.dart';
import 'package:npsh3/models/observation_point.dart';
import 'package:npsh3/models/point.dart';
import 'package:npsh3/models/ensayo.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NpshProvider extends ChangeNotifier {
  late Ensayo ensayo;

  NpshProvider() {
    ensayo = Ensayo();
    initializePoints();
  }

  List<Point> get allPoints => ensayo.allPoints;
  List<List<ObservationPoint>> get allObservationPoints =>
      ensayo.allObservationPoints;
  List<NpshPoint> get allNpshPoints => ensayo.allNpshPoints;
  String get marca => ensayo.marca;
  String get serie => ensayo.serie;
  num get potencia => ensayo.potencia;
  num get densidad => ensayo.densidad;
  num get pvapor => ensayo.pvapor;
  num get temperatura => ensayo.temperatura;

  void initializePoints() {
    ensayo.initializePoints();
    notifyListeners();
  }

  void updateDensidad({required num newDensidad}) {
    ensayo.updateDensidad(newDensidad: newDensidad);
    notifyListeners();
  }

  void updateTemperatura({required num newTemperatura}) {
    ensayo.updateTemperatura(newTemperatura: newTemperatura);
    notifyListeners();
  }

  void updatePresionEntrada(
      {required String id, required num newPresionEntrada}) {
    ensayo.updatePresionEntrada(id: id, newPresionEntrada: newPresionEntrada);
    notifyListeners();
  }

  void updateQ({required String id, required num newQ}) {
    ensayo.updateQ(id: id, newQ: newQ);
    notifyListeners();
  }

  void updatePresionSalida(
      {required String id, required num newPresionSalida}) {
    ensayo.updatePresionSalida(id: id, newPresionSalida: newPresionSalida);
    notifyListeners();
  }

  void updateMarca({required String newMarca}) {
    ensayo.updateMarca(newMarca: newMarca);
  }

  void updateSerie({required String newSerie}) {
    ensayo.updateSerie(newSerie: newSerie);
  }

  void updatePotencia({required num newPotencia}) {
    ensayo.updatePotencia(newPotencia: newPotencia);
  }

  bool get isReady => ensayo.isReady;

  void updateQObservationPoint(
      {required String id, required int index, required num newQ}) {
    ensayo.updateQObservationPoint(id: id, index: index, newQ: newQ);
    notifyListeners();
  }

  void updatePresionEntradaObservationPoint(
      {required String id, required int index, required num pEntrada}) {
    ensayo.updatePresionEntradaObservationPoint(
        id: id, index: index, pEntrada: pEntrada);
    notifyListeners();
  }

  void updatePresionSalidaObservationPoint(
      {required String id, required int index, required num pSalida}) {
    ensayo.updatePresionSalidaObservationPoint(
        id: id, index: index, pSalida: pSalida);
    notifyListeners();
  }

  void setObservationPointQ({required int index, required num newQ}) {
    ensayo.setObservationPointQ(index: index, newQ: newQ);
    notifyListeners();
  }

  bool observationPointDeltaGreaterThan3({required int index}) {
    return ensayo.observationPointDeltaGreaterThan3(index: index);
  }

  bool isTestComplete() {
    return ensayo.isTestComplete();
  }

  void generateNPSH3() {
    ensayo.generateNPSH3();
    notifyListeners();
  }

  Future<void> guardarEnsayo() async {
    var prefs = await SharedPreferences.getInstance();
    final storedEnsayos = prefs.getStringList('storage_npsh10') ?? [];

    final jsonEnsayo = jsonEncode(ensayo.toJson());

    final formattedEnsayo = {
      'id': ensayo.id,
      'data': jsonEnsayo,
      'savedAt': DateTime.now().toIso8601String()
    };

    final encodedEnsayo = jsonEncode(formattedEnsayo);
    storedEnsayos.insert(0, encodedEnsayo);

    await prefs.setStringList('storage_npsh10', storedEnsayos);
    notifyListeners();
  }

  void cargarEnsayo(Ensayo nuevoEnsayo) {
    ensayo = nuevoEnsayo;
    notifyListeners();
  }

  void nuevoEnsayo() {
    ensayo = Ensayo();
    notifyListeners();
  }

  Future<List<EnsayoIndex>> getEnsayosGuardados() async {
    var prefs = await SharedPreferences.getInstance();
    final storedEnsayos = prefs.getStringList('storage_npsh10') ?? [];

    final decodedStoredEnsayos = storedEnsayos
        .map((encoded) => jsonDecode(encoded) as Map<String, dynamic>)
        .map((decoded) => {
              'id': decoded['id'],
              'savedAt': decoded['savedAt'],
              'data': jsonDecode(decoded['data'])
            })
        .toList();

    final entries = decodedStoredEnsayos
        .map((entry) => EnsayoIndex.fromJson(entry))
        .toList();
    return entries;
  }
}

class EnsayoIndex {
  String id;
  String savedAt;
  Ensayo data;

  EnsayoIndex(this.id, this.savedAt, this.data);

  Map<String, dynamic> toJson() =>
      {'id': id, 'savedAt': savedAt, 'data': data.toJson()};

  EnsayoIndex.fromJson(Map<String, dynamic> json)
      : id = json['id'] as String,
        savedAt = (json['savedAt'] as String),
        data = Ensayo.fromJson(json['data']);
}
