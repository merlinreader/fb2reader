import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:merlin/components/appbar/appbar.dart';
//import 'package:merlin/components/navbar/navbar.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/style/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'dart:async';

class Recent extends StatelessWidget {
  const Recent({super.key});
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: RecentPage(),
    );
  }
}

class RecentPage extends StatefulWidget {
  const RecentPage({super.key});
  @override
  State<RecentPage> createState() => _RecentPage();
}

class BookImageWidget extends StatelessWidget {
  final List<String> imagePaths;

  const BookImageWidget({required this.imagePaths, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: imagePaths.map((imagePath) {
        return Column(
          children: [
            Image.file(
              File(imagePath),
              width: MediaQuery.of(context).size.width / 2.35,
            ),
            const TextTektur(
              text: "Название книги",
              fontsize: 12,
              textColor: MyColors.black,
            ),
            const TextTektur(
              text: "Автор книги",
              fontsize: 12,
              textColor: MyColors.black,
            ),
          ],
        );
      }).toList(),
    );
  }
}

class _RecentPage extends State<RecentPage> {
  final ScrollController _scrollController = ScrollController();
  bool isVisible = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        isVisible = _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  final List<List<String>> _bookImages = [];

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(type: FileType.image);
      final filePath =
          result?.files.isNotEmpty == true ? result?.files.single.path : null;

      if (filePath != null) {
        final file = File(filePath);
        final fileName = path.basename(file.path);
        final appDir = await getApplicationDocumentsDirectory();
        final savedImage = await file.copy('${appDir.path}/$fileName');

        setState(() {
          if (_bookImages.isEmpty || _bookImages.last.length == 2) {
            // Создайте новую строку, если список пуст или последняя строка содержит уже 2 книги
            _bookImages.add([savedImage.path]);
          } else {
            // Добавьте книгу к последней строке
            _bookImages.last.add(savedImage.path);
          }
        });
      }
    } catch (e) {
      print("Ошибка при выборе файла: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      //bottomNavigationBar: const CustomNavBar(),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                controller: _scrollController,
                itemCount: _bookImages.length,
                itemBuilder: (context, index) {
                  return BookImageWidget(
                    imagePaths: _bookImages[index],
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        child: const Icon(Icons.add),
      ),
    );
  }
}

void testbutton() {
  print("123");
}
