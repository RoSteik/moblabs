import 'dart:convert';

import 'package:moblabs/lab2/logic/model/fitness_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class IFitnessDataService {

  Future<List<FitnessData>> loadFitnessDataList();
  Future<void> saveFitnessDataList(List<FitnessData> dataList);
  Future<void> addFitnessData(FitnessData data);
  Future<void> deleteFitnessData(int index);


}


class FitnessDataService implements IFitnessDataService{
  static const _fitnessDataKey = 'fitnessData';

  @override
  Future<List<FitnessData>> loadFitnessDataList() async {
    final prefs = await SharedPreferences.getInstance();
    final fitnessDataString = prefs.getString(_fitnessDataKey);
    if (fitnessDataString != null) {
      final List<dynamic> jsonDataList =
      jsonDecode(fitnessDataString) as List<dynamic>;
      return jsonDataList
          .map((jsonData) =>
          FitnessData.fromJson(jsonData as Map<String, dynamic>),)
          .toList();
    }
    return [];
  }

  @override
  Future<void> saveFitnessDataList(List<FitnessData> dataList) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_fitnessDataKey,
      jsonEncode(dataList.map((data) => data.toJson()).toList()),);
  }

  @override
  Future<void> addFitnessData(FitnessData data) async {
    final dataList = await loadFitnessDataList();
    dataList.add(data);
    await saveFitnessDataList(dataList);
  }

  @override
  Future<void> deleteFitnessData(int index) async {
    final dataList = await loadFitnessDataList();
    if (index >= 0 && index < dataList.length) {
      dataList.removeAt(index);
      await saveFitnessDataList(dataList);
    }
  }
}
