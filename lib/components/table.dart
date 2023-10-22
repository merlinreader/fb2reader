import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';
import 'dart:convert';

class StatTable extends StatelessWidget {
  const StatTable({Key? key}) : super(key: key);

  Future<List<dynamic>> parseJsonFile(
      BuildContext context, String filePath) async {
    String jsonData = await DefaultAssetBundle.of(context).loadString(filePath);
    return json.decode(jsonData);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: FutureBuilder<List<dynamic>>(
      future: parseJsonFile(context, 'assets/stat.json'),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          final dataList = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.only(top: 8.0, right: 1),
            child: DataTable(
              columnSpacing: 15,
              columns: const [
                DataColumn(label: Text('Имя')),
                DataColumn(label: Text('Страниц')),
                DataColumn(label: Text('Страниц в \nрежиме слова')),
              ],
              rows: [
                ...List.generate(
                  dataList.length,
                  (index) => DataRow(
                    cells: [
                      DataCell(Text(dataList[index]['firstName'])),
                      DataCell(
                          Text(dataList[index]['totalPageCount'].toString())),
                      DataCell(Text(
                          dataList[index]['totalPageCountMode'].toString())),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    ));
  }
}
