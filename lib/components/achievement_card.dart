import 'package:flutter/material.dart';
import 'package:merlin/components/achievement.dart';
import 'package:intl/intl.dart';
import 'package:merlin/style/colors.dart';

class AchievementCard extends StatelessWidget {
  final Achievement achievement;

  const AchievementCard({
    required this.achievement,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 18, right: 18),
      child: Container(
        width: mediaQuery.size.width - 48,
        height: 83.0,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: achievement.isReceived ? Theme.of(context).colorScheme.scrim.withOpacity(0.2) : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 16, top: 16, bottom: 16, right: 8),
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Image.network(
                      achievement.picture,
                      width: 48,
                      height: 48,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.scrim.withOpacity(achievement.isReceived ? 0 : 0.8),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                ],
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
                      color:
                          achievement.isReceived ? Theme.of(context).colorScheme.onSurface : Theme.of(context).colorScheme.onSurface.withOpacity(0.2),
                    ),
                  ),
                ),
                achievement.date == null
                    ? const SizedBox.shrink()
                    : Text(
                        (DateFormat('dd.MM.yyyy').format(achievement.date!)),
                        style: TextStyle(
                          fontFamily: 'Tektur',
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: achievement.isReceived ? Colors.grey : Colors.grey.withOpacity(0.2),
                        ),
                      ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
