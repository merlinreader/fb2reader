import 'package:flutter/material.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/pages/settings/settings.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class StatTable extends StatelessWidget {
  final String path;
  final String country;
  final String area;
  final String city;

  const StatTable({
    required this.path,
    required this.country,
    required this.area,
    required this.city,
    Key? key,
  }) : super(key: key);

  Future<List<dynamic>> fetchJson() async {
    final url = Uri.parse(
        'https://fb2.cloud.leam.pro/api/statistic/$path?sortBy=totalPageCountWordMode&country=$country&area=$area&city=$city');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Обработка полученного JSON-объекта здесь
      return jsonResponse ?? [];
    } else {
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
                data: isDarkTheme ? darkTheme() : lightTheme(),
                child: DataTable(
                  dividerThickness: 0.0,
                  // ignore: deprecated_member_use
                  dataRowHeight: 38,
                  //headingRowColor: MaterialStateColor.resolveWith(
                  //  (states) => MyColors.white),
                  //dataRowColor: MaterialStateColor.resolveWith(
                  //(states) => MyColors.white),
                  columnSpacing: 15,
                  columns: const [
                    DataColumn(
                      label: Text11Bold(
                        text: 'Имя',
                        textColor: MyColors.grey,
                      ),
                    ),
                    DataColumn(
                      label: Text11Bold(
                        text: 'Страниц',
                        textColor: MyColors.grey,
                      ),
                    ),
                    DataColumn(

                      label: Text11(

                        text: 'Страниц в\nрежиме слова',
                        textColor: MyColors.grey,
                      ),
                    ),
                  ],
                  rows: List.generate(
                    dataList.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(

                          Text11(

                            text: dataList[index]['firstName']?.length > 10
                                ? '${dataList[index]['firstName']?.substring(0, 10)}...'
                                : dataList[index]['firstName'] ?? '',
                            textColor: MyColors.black,
                          ),
                        ),
                        DataCell(
                          Text11(
                            text: dataList[index]['totalPageCountSimpleMode']
                                    ?.toString() ??
                                '',
                            textColor: MyColors.black,
                          ),
                        ),
                        DataCell(
                          Text11(
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

            // return const Row(
            //   children: [
            //     SizedBox(width: 20),
            //     Text('Наш сервер сейчас отдыхает, извините за неудобства: ${snapshot.error}'),
            //   ],
            // );
            return Text('Ошибка: ${snapshot.error}');

          } else {
            return const Center(
                child: Column(children: [
              SizedBox(height: 20),
              SizedBox(
                width: 30, // Задайте желаемую ширину
                height: 30, // Задайте желаемую высоту
                child: CircularProgressIndicator(),
              ),
            ]));
          }
        },
      ),
    );
  }
}
