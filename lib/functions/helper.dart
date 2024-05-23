import 'package:is_first_run/is_first_run.dart';

Future<bool> firstRun() async {
  bool firstRun = await IsFirstRun.isFirstRun();
  return firstRun;
}

Future<void> firstRunReset() async {
  await IsFirstRun.reset();
}