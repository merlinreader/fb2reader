import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:merlin/components/appbar/appbar.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/UI/icon/custom_icon.dart';

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
  final String imagePath;
  const BookImageWidget({required this.imagePath, super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Image.file(File(imagePath),
            width: MediaQuery.of(context).size.width / 2.35),
        const TextTektur(
            text: "Название книги", fontsize: 12, textColor: MyColors.black),
        const TextTektur(
            text: "Автор книги", fontsize: 12, textColor: MyColors.black),
      ],
    );
  }
}

class _RecentPage extends State<RecentPage> {
  final ScrollController _scrollController = ScrollController();
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      setState(() {
        _isVisible = _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse;
      });
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(24, 28, 24, 24),
          child: MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: ListView(
                controller: _scrollController,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const TextTektur(
                          text: "Последнее",
                          fontsize: 32,
                          textColor: MyColors.black),
                      Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              0, 10, 0, 10),
                          child: Row(
                            children: [
                              Center(
                                  child: Column(
                                children: [
                                  Image.network(
                                    'https://avidreaders.ru/pics/1/0/3210.jpg',
                                    width: MediaQuery.of(context).size.width /
                                        2.35,
                                  ),
                                  const TextTektur(
                                      text: "Обломов",
                                      fontsize: 12,
                                      textColor: MyColors.black),
                                  const TextTektur(
                                      text: "Иван Гончаров",
                                      fontsize: 12,
                                      textColor: MyColors.black)
                                ],
                              )),
                              const Spacer(),
                              Center(
                                  child: Column(
                                children: [
                                  Image.network(
                                    'https://avidreaders.ru/pics/1/0/3210.jpg',
                                    width: MediaQuery.of(context).size.width /
                                        2.35,
                                  ),
                                  const TextTektur(
                                      text: "Обломов",
                                      fontsize: 12,
                                      textColor: MyColors.black),
                                  const TextTektur(
                                      text: "Иван Гончаров",
                                      fontsize: 12,
                                      textColor: MyColors.black)
                                ],
                              )),
                            ],
                          )),
                      Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                          child: Row(
                            children: [
                              Center(
                                  child: Column(
                                children: [
                                  Image.network(
                                    'https://avidreaders.ru/pics/1/0/3210.jpg',
                                    width: MediaQuery.of(context).size.width /
                                        2.35,
                                  ),
                                  const TextTektur(
                                      text: "Обломов",
                                      fontsize: 12,
                                      textColor: MyColors.black),
                                  const TextTektur(
                                      text: "Иван Гончаров",
                                      fontsize: 12,
                                      textColor: MyColors.black)
                                ],
                              )),
                              const Spacer(),
                              Center(
                                  child: Column(
                                children: [
                                  Image.network(
                                    'https://avidreaders.ru/pics/1/0/3210.jpg',
                                    width: MediaQuery.of(context).size.width /
                                        2.35,
                                  ),
                                  const TextTektur(
                                      text: "Обломов",
                                      fontsize: 12,
                                      textColor: MyColors.black),
                                  const TextTektur(
                                      text: "Иван Гончаров",
                                      fontsize: 12,
                                      textColor: MyColors.black)
                                ],
                              )),
                            ],
                          )),
                      Padding(
                          padding:
                              const EdgeInsetsDirectional.fromSTEB(0, 0, 0, 10),
                          child: Row(
                            children: [
                              Center(
                                  child: Column(
                                children: [
                                  Image.network(
                                    'https://avidreaders.ru/pics/1/0/3210.jpg',
                                    width: MediaQuery.of(context).size.width /
                                        2.35,
                                  ),
                                  const TextTektur(
                                      text: "Обломов",
                                      fontsize: 12,
                                      textColor: MyColors.black),
                                  const TextTektur(
                                      text: "Иван Гончаров",
                                      fontsize: 12,
                                      textColor: MyColors.black)
                                ],
                              )),
                              const Spacer(),
                              Center(
                                  child: Column(
                                children: [
                                  Image.network(
                                    'https://avidreaders.ru/pics/1/0/3210.jpg',
                                    width: MediaQuery.of(context).size.width /
                                        2.35,
                                  ),
                                  const TextTektur(
                                      text: "Обломов",
                                      fontsize: 12,
                                      textColor: MyColors.black),
                                  const TextTektur(
                                      text: "Иван Гончаров",
                                      fontsize: 12,
                                      textColor: MyColors.black)
                                ],
                              )),
                            ],
                          )),
                    ],
                  ),
                ],
              ))),
      appBar: const CustomAppBar(),
      //bottomNavigationBar: const CustomNavBar(),
      floatingActionButton: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: _isVisible ? 0.0 : 1.0,
        child: const FloatingActionButton(
          onPressed: testbutton,
          backgroundColor: MyColors.purple,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.zero)),
          autofocus: true,
          child: Icon(CustomIcons.bookOpen),
        ),
      ),
    );
  }
}

void testbutton() {
  print("123");
}
