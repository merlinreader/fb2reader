import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StatTable extends StatelessWidget {
  Future<List<dynamic>> fetchJson() async {
    final url = Uri.parse(
        'https://aipro-energy.leam.pro/statistic/annual?sortBy=totalPageCountWordMode');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Обработка полученного JSON-объекта здесь
      return jsonResponse ?? [];
    } else {
      print('Ошибка запроса: ${response.statusCode}');
      return []; // Возвращаем пустой список в случае ошибки
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: FutureBuilder<List<dynamic>>(
        future: fetchJson(),
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
                  // ignore: deprecated_member_use
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
                      ),
                    ),
                    DataColumn(
                      label: Text11(
                        text: 'Страниц',
                        textColor: MyColors.grey,
                      ),
                    ),
                    DataColumn(
                      label: Text11(
                        text: 'Страниц в \nрежиме слова',
                        textColor: MyColors.grey,
                      ),
                    ),
                  ],
                  rows: List.generate(
                    dataList.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(
                          Text11Bold(
                            text: dataList[index]['firstName'] ?? '',
                            textColor: MyColors.black,
                          ),
                        ),
                        DataCell(
                          Text11Bold(
                            text: dataList[index]['totalPageCountSimpleMode']
                                    ?.toString() ??
                                '',
                            textColor: MyColors.black,
                          ),
                        ),
                        DataCell(
                          Text11Bold(
                            text: dataList[index]['totalPageCountWordMode']
                                    ?.toString() ??
                                '',
                            textColor: MyColors.black,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Ошибка: ${snapshot.error}');
          } else {
            return const CircularProgressIndicator();
          }
        },
      ),
    );
  }
}
