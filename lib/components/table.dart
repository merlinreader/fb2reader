import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
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
              child: Theme(
                // Theme для отключения divider
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: DataTable(
                  dividerThickness: 0.0,
                  dataRowHeight: 38,
                  headingRowColor: MaterialStateColor.resolveWith(
                      (states) => MyColors.white),
                  dataRowColor: MaterialStateColor.resolveWith(
                      (states) => MyColors.white),
                  columnSpacing: 15,
                  columns: const [
                    DataColumn(
                        label: Text11(
                      text: 'Имя',
                      textColor: MyColors.grey,
                    )),
                    DataColumn(
                        label: Text11(
                      text: 'Страниц',
                      textColor: MyColors.grey,
                    )),
                    DataColumn(
                        label: Text11(
                      text: 'Страниц в \nрежиме слова',
                      textColor: MyColors.grey,
                    )),
                  ],
                  rows: [
                    ...List.generate(
                      dataList.length,
                      (index) => DataRow(
                        cells: [
                          DataCell(Text11Bold(
                            text: dataList[index]['firstName'],
                            textColor: MyColors.black,
                          )),
                          DataCell(Text11Bold(
                            text: dataList[index]['totalPageCount'].toString(),
                            textColor: MyColors.black,
                          )),
                          DataCell(Text11Bold(
                            text: dataList[index]['totalPageCountMode']
                                .toString(),
                            textColor: MyColors.black,
                          )),
                        ],
                      ),
                    ),
                  ],
                ),
              ));
        } else if (snapshot.hasError) {
          return Text('Ошибка: ${snapshot.error}');
        } else {
          return CircularProgressIndicator();
        }
      },
    ));
  }
}
