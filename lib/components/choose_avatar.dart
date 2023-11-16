import 'package:flutter/material.dart';
import 'package:merlin/components/achievement.dart';
import 'package:intl/intl.dart';

class AvatarList extends StatelessWidget {
  final Achievement achievement;

  const AvatarList({
    required this.achievement,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58.0,
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
        ],
      ),
    );
  }
}

/*
ListView(
                  children: [
                    ..._achievements
                        .where((achievement) => achievement.isReceived)
                        .map((e) => AchievementCard(achievement: e))
                        .toList()
                  ],
                ),
*/