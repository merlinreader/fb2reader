import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/main.dart';
import 'package:provider/provider.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class StatTable extends StatefulWidget {
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

  @override
  // ignore: library_private_types_in_public_api
  _StatTableState createState() => _StatTableState();
}

class _StatTableState extends State<StatTable> {
  String? id;

  @override
  void initState() {
    super.initState();
    getId();
  }

  Future<void> getId() async {
    const FlutterSecureStorage secureStorage = FlutterSecureStorage();
    String? tokenSecure;
    try {
      tokenSecure = await secureStorage.read(key: 'token');
    } catch (e) {
      tokenSecure = null;
    }
    String token = '';
    if (tokenSecure != null) {
      token = tokenSecure;
    }
    final prefs = await SharedPreferences.getInstance();
    const url = 'https://merlin.su/account/';
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {'Authorization': 'Bearer $token'},
      );
      final data = json.decode(response.body);
      final fetchedId = data['_id'];
      // debugPrint(fetchedId.toString());
      if (response.statusCode == 200) {
        if (mounted) {
          setState(() {
            id = fetchedId.toString();
          });
        }
      } else {
        if (mounted) {
          setState(() {
            id = prefs.getString('deviceId');
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          id = prefs.getString('deviceId');
        });
      }
    }
  }

  Future<List<dynamic>> fetchJson() async {
    final url = Uri.parse(
        'https://merlin.su/statistic/${widget.path}?sortBy=totalPageCountWordMode&country=${widget.country}&area=${widget.area}&city=${widget.city}&userId=$id');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      return jsonResponse ?? [];
    } else {
      return [];
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
            final themeProvider = Provider.of<ThemeProvider>(context);
            return Padding(
              padding: const EdgeInsets.only(top: 8.0, right: 1),
              child: Theme(
                // Theme для отключения divider
                data: themeProvider.isDarkTheme ? darkTheme() : lightTheme(),
                child: DataTable(
                  dividerThickness: 0.0,
                  // ignore: deprecated_member_use
                  dataRowHeight: 38,
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
                        text: 'Страниц в\nрежиме Слово',
                        textColor: MyColors.grey,
                      ),
                    ),
                  ],
                  rows: List.generate(
                    dataList.length,
                    (index) => DataRow(
                      cells: [
                        DataCell(
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: Image.network(
                                  dataList[index]['picture'],
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text11(
                                text: dataList[index]['_id'] == id
                                    ? '> Вы'
                                    : dataList[index]['firstName']?.length > 10
                                        ? '${dataList[index]['firstName']?.substring(0, 10)}...'
                                        : dataList[index]['firstName'] ?? '',
                                textColor: dataList[index]['_id'] == id ? MyColors.purple : MyColors.black,
                              ),
                            ],
                          ),
                        ),
                        DataCell(
                          Text11(
                            text: dataList[index]['totalPageCountSimpleMode']?.toString() ?? '',
                            textColor: MyColors.black,
                          ),
                        ),
                        DataCell(
                          Text11(
                            text: dataList[index]['totalPageCountWordMode']?.toString() ?? '',
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
            return const Center(
                child: Column(
              children: [
                SizedBox(height: 30),
                Text('Проверьте подключение к Интернету'),
              ],
            ));
          } else {
            return const Center(
                child: Column(children: [
              SizedBox(height: 20),
              SizedBox(
                width: 30, // Задайте желаемую ширину
                height: 30, // Задайте желаемую высоту
                child: CircularProgressIndicator(
                  color: MyColors.purple,
                ),
              ),
            ]));
          }
        },
      ),
    );
  }
}
