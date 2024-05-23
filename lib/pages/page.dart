// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:merlin/UI/icon/custom_icon.dart';
import 'package:merlin/UI/router.dart';
import 'package:merlin/pages/loading/loading.dart';
import 'package:merlin/pages/profile/profile.dart';
import 'package:merlin/pages/profile/profile_view_model.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/pages/achievements/achievements.dart';
import 'package:merlin/style/text.dart';
import 'package:merlin/pages/recent/recent.dart';
import 'package:merlin/components/svg/svg_asset.dart';
import 'package:merlin/pages/recent/imageloader.dart';
import 'package:merlin/pages/statistic/statistic.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:merlin/functions/helper.dart';

class AppPage extends StatefulWidget {
  const AppPage({super.key});

  @override
  Page createState() => Page();
}

class Page extends State<AppPage> {
  int _selectedPage = 1;
  String bookName = '';
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  final GlobalKey _four = GlobalKey();
  final GlobalKey _five = GlobalKey();
  BuildContext? myContext;

  static const List<Widget> _widgetOptions = <Widget>[
    LoadingScreen(),
    RecentPage(),
    AchievementsPage(),
    StatisticPage(),
  ];

  @override
  void initState() {
    getBookName();
    WidgetsBinding.instance.addPostFrameCallback(
          (_) => Future.delayed(const Duration(milliseconds: 300), () async {
            if (await firstRun()) {
              ShowCaseWidget.of(myContext!).startShowCase(
                  [ _one, _two, _three, _four, _five]);
            }
            //await firstRunReset();
      }),
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getBookName();
  }

  Future<void> getBookName() async {
    final prefs = await SharedPreferences.getInstance();
    bookName = prefs.getString('fileTitle') ?? '';
  }

  void onSelectTab(int index) async {
    //if (index == _selectedPage) return;
    setState(() {
      profile = false;
      _widgetOptions[index];
      _selectedPage = index;
    });
    if (index == 0) {
      await ImageLoader().loadImage();
      final prefs = await SharedPreferences.getInstance();
      bool check = prefs.getBool('success') ?? false;
      if (check) {
        await Navigator.pushNamed(context, RouteNames.reader);
      }
      setState(() {
        profile = false;
        _selectedPage = 1;
        _widgetOptions[1];
      });
    }
  }

  bool profile = false;
  final ImageLoader imageLoader = ImageLoader();

  @override
  Widget build(BuildContext context) {
    return ShowCaseWidget(
        builder: Builder(
          builder: (context) {
            myContext = context;
            return Scaffold(
              appBar: AppBar(
                backgroundColor: Theme.of(context).colorScheme.primary,
                elevation: 0.5,
                title: GestureDetector(
                  onTap: () {
                    setState(() {
                      profile = true;
                    });
                  },
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 6, right: 16),
                        child: SvgPicture.asset(
                          SvgAsset.merlinLogo,
                        ),
                      ),
                      const Text24(text: 'Merlin', textColor: MyColors.black),
                    ],
                  ),
                ),
              ),
              bottomNavigationBar: BottomNavigationBar(
                currentIndex: _selectedPage,
                backgroundColor: Theme.of(context).colorScheme.primary,
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: Showcase(
                      key: _three,
                      title: 'Книги',
                      description: "Для выбора книги, нажмите на иконку книги внизу экрана. Предоставьте приложению права для доступа к внутренней памяти.\n"
                                   "- Файлы наших книг имеют расширение fd2 или fb2.zip. Откройте книгу.\n"
                                   "- Для листания вперед нажимайте на правый, левый и нижний край экрана. Для листания назад, нажимайте на верхний край экрана. Так же можно двигать текст книги свайпом вверх или вниз.\n"
                                   "- При нажатии на центр экрана появляются верхний и нижний колонтитулы.",
                      disableMovingAnimation: true,
                      onToolTipClick: () {
                        ShowCaseWidget.of(context).completed(_three);
                      },
                      child: const Icon(
                        CustomIcons.bookOpen,
                      ),
                    ),
                    label: 'Книги',
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                      key: _one,
                      title: 'Последние книги',
                      description: 'Вы находитесь в списке последних открытых книг',
                      disableMovingAnimation: true,
                      onToolTipClick: () {
                        ShowCaseWidget.of(context).completed(_one);
                      },
                      child: const Icon(
                        CustomIcons.clock,
                      ),
                    ),
                    label: 'Последнее',
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                        key: _four,
                        description: "На вкладке достижения можно увидеть заслуженные вами Ачивки.\n"
                                     "В дальнейшем наличие Ачивок будет давать дополнительные преимущества при использовании наших приложений.",
                        disableMovingAnimation: true,
                        onToolTipClick: () {
                          ShowCaseWidget.of(context).completed(_four);
                        },
                        child: const Icon(
                            CustomIcons.trophy
                        )
                    ),
                    label: 'Достижения',
                  ),
                  BottomNavigationBarItem(
                    icon: Showcase(
                        key: _five,
                        disableMovingAnimation: true,
                        description: "Статистика. На вкладке  учитывается количество страниц в режиме чтения и в режиме Слово, которые вы прочитали за разные промежутки времени.\nРейтинг пользователей составляется за день, неделю, месяц, полгода, год, в разрезе города, региона, страны. Статистика попадает на сервер за прошедшие сутки и выгружается раз в 24 часа.\n"
                                     "Если вы не авторизованный пользователь, вы увидите свою статистику на сервере только за 24 часа",
                        onToolTipClick: () {
                          ShowCaseWidget.of(context).completed(_five);
                        },
                        child: const Icon(
                            CustomIcons.chart
                        )
                    ),
                    label: 'Статистика',
                  ),
                ],
                onTap: (index) {
                  onSelectTab(index);
                },
                selectedItemColor: profile == true ? MyColors.grey : MyColors.purple,
                unselectedItemColor: MyColors.grey,
                showUnselectedLabels: true,
                selectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Tektur',
                  fontWeight: FontWeight.bold,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 11,
                  fontFamily: 'Tektur',
                  fontWeight: FontWeight.bold,
                ),
              ),
              body: profile == true
                  ? ChangeNotifierProvider(
                create: (context) => ProfileViewModel(context),
                child: const Profile(),
              )
                  : _widgetOptions[_selectedPage],
              floatingActionButton: profile == false
                  ? FloatingActionButton(
                onPressed: () async {
                  await getBookName();
                  try {
                    // if (RecentPageState().checkBooks() == true) {
                    //   Fluttertoast.showToast(
                    //     msg: 'Нет последней книги',
                    //     toastLength: Toast.LENGTH_SHORT, // Длительность отображения
                    //     gravity: ToastGravity.BOTTOM,
                    //   ); // Расположение уведомления
                    // } else {
                    if (bookName == '') {
                      Fluttertoast.showToast(
                        msg: 'Нет последней книги',
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                      );
                    } else {
                      Navigator.pushNamed(context, RouteNames.reader);
                    }
                    return;
                  } catch (e) {
                    Fluttertoast.showToast(
                      msg: 'Нет последней книги',
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                    );
                  }
                },
                backgroundColor: MyColors.purple,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.zero)),
                autofocus: true,
                child: Showcase(
                    key: _two,
                    disableMovingAnimation: true,
                    description: "Нажав на такую иконку вы можете продолжить читать любую ранее начатую книгу",
                    onToolTipClick: () {
                      ShowCaseWidget.of(context).completed(_two);
                    },
                    child: Icon(
                      CustomIcons.bookOpen,
                      color: Theme.of(context).colorScheme.background,
                    )
                ),
              )
                  : null,
            );
          },
        )
    );
  }
}
