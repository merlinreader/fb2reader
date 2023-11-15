import 'package:flutter/material.dart';
import 'package:merlin/components/achievement.dart';
import 'package:intl/intl.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({
    required this.achievement,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Container(
      width: mediaQuery.size.width - 48,
      height: 83.0,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: achievement.isReceived
            ? Colors.white.withOpacity(0.2)
            : Colors.transparent,
      ),
      child: Row(
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding:
                const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8),
            child: Image.network(
              achievement.picture,
              width: 48,
              height: 48,
              color: achievement.isReceived
                  ? null
                  : Colors.transparent.withOpacity(0.5),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  achievement.description,
                  style: TextStyle(
                    fontFamily: 'Tektur',
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: achievement.isReceived
                        ? Colors.black
                        : Colors.black.withOpacity(0.2),
                  ),
                ),
              ),
              achievement.date == null
                  ? SizedBox.shrink()
                  : Text(
                      (DateFormat('dd.MM.yyyy').format(achievement.date!)),
                      style: TextStyle(
                        fontFamily: 'Tektur',
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: achievement.isReceived
                            ? Colors.grey
                            : Colors.grey.withOpacity(0.2),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }
}
