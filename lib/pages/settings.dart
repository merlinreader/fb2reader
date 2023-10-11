import 'package:flutter/material.dart';
import 'package:merlin/style/colors.dart';
import 'package:flutter_svg/flutter_svg.dart';

void main() {
  runApp(const MySettings());
}

class MySettings extends StatelessWidget {
  const MySettings({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const SettingsPage(),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool darkBackground = false;
  Color textColor = Colors.black;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: MyColors.white,
        leading: SvgPicture.asset(
          'assets/images/chevron-left.svg',
          width: 16,
          height: 16,
        ),
        // leading: IconButton(
        //   icon: const Icon(Icons.arrow_back),
        //   onPressed: () {
        //     Navigator.pop(context); // return button
        //   },
        // ),
        title: const Text(
          'Настройки',
          style: TextStyle(
              color: MyColors.black, fontFamily: 'Tektur', fontSize: 16),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            height: 1.0,
            color: const Color.fromRGBO(235, 235, 235, 1),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildColorSettingsSection(),
          const Divider(),
          _buildReaderExample(),
        ],
      ),
    );
  }

  Widget _buildColorSettingsSection() {
    return Column(
      children: [
        _buildSettingOption(
          'Фон белый',
          darkBackground,
          Colors.white,
        ),
        _buildSettingOption(
          'Фон черный',
          !darkBackground,
          Colors.black,
        ),
        _buildSettingOption(
          'Текст чёрный',
          textColor == Colors.black,
          Colors.black,
        ),
        _buildSettingOption(
          'Текст красный',
          textColor == Colors.red,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildSettingOption(String title, bool value, Color color) {
    return ListTile(
      title: Text(title),
      trailing: Checkbox(
        value: value,
        onChanged: (newValue) {
          setState(() {
            if (title.contains('Фон')) {
              darkBackground = !value;
            } else {
              textColor = color;
            }
          });
        },
      ),
    );
  }

  Widget _buildReaderExample() {
    return Container(
        width: 312,
        height: 56,
        decoration: BoxDecoration(
            color: darkBackground ? Colors.black : Colors.white,
            border: Border.all(
              color: const Color.fromRGBO(235, 235, 235, 1),
              width: 2,
            )),
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Text(
            'Текст примера',
            style:
                TextStyle(color: textColor, fontFamily: 'Roboto', fontSize: 14),
          ),
        ));
  }
}
