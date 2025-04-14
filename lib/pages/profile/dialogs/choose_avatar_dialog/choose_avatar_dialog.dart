import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:merlin/UI/theme/theme.dart';
import 'package:merlin/components/svg/svg_widget.dart';
import 'package:merlin/main.dart';
import 'package:merlin/pages/profile/dialogs/choose_avatar_dialog/choose_avatar_dialog_view_model.dart';
import 'package:merlin/style/colors.dart';
import 'package:merlin/style/text.dart';
import 'package:provider/provider.dart';

Future<bool?> showChooseAvatarDialog(BuildContext context) async {
  return await showDialog(
      context: context,
      builder: (context) => ChangeNotifierProvider(
            create: (context) => ChooseAvatarDialogViewModel(context),
            child: _ChooseAvatarDialog(),
          ));
}

class _ChooseAvatarDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    final avatarsList =
        context.watch<ChooseAvatarDialogViewModel>().avatarsList;
    final storedAvatar =
        context.watch<ChooseAvatarDialogViewModel>().storedAvatar;
    final selectedAvatar =
        context.watch<ChooseAvatarDialogViewModel>().selectedAvatar;
    final isLoading = context.watch<ChooseAvatarDialogViewModel>().isLoading;
    final setSelectedAvatar =
        context.read<ChooseAvatarDialogViewModel>().setSelectedAvatar;
    final onSaveClick = context.read<ChooseAvatarDialogViewModel>().onSaveClick;
    final onResetClick =
        context.read<ChooseAvatarDialogViewModel>().onResetClick;

    return Theme(
      data: themeProvider.isDarkTheme ? darkTheme() : lightTheme(),
      child: AlertDialog(
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10.0))),
        alignment: Alignment.center,
        titlePadding: const EdgeInsets.only(top: 10, bottom: 10),
        title: Center(
            child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: SizedBox(
                  height: 65,
                  width: 65,
                  child: selectedAvatar != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(50),
                          child: CachedNetworkImage(
                            imageUrl: selectedAvatar,
                            errorWidget: (context, url, error) =>
                                storedAvatar != null
                                    ? Image.memory(storedAvatar)
                                    : const MerlinWidget(),
                          ))
                      : const MerlinWidget()),
            ),
            const Text24(text: 'Аватар'),
            const SizedBox(
              height: 10,
            ),
            Container(
              height: 10,
              width: double.infinity,
              color: themeProvider.isDarkTheme
                  ? MyColors.grey
                  : MyColors.lightGray,
            ),
          ],
        )),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Center(
              child: Text16(text: 'Выберите аватар'),
            ),
            Container(
              padding: const EdgeInsets.only(top: 15),
              height: MediaQuery.of(context).size.height / 3,
              width: MediaQuery.of(context).size.width,
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: MyColors.purple,
                      ),
                    )
                  : GridView.builder(
                      itemCount: avatarsList.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4),
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            setSelectedAvatar(avatarsList[index]);
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(6.0),
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: const [
                                  BoxShadow(
                                      color: MyColors.black,
                                      offset: Offset.zero,
                                      blurRadius: 5,
                                      spreadRadius: 0.1,
                                      blurStyle: BlurStyle.normal)
                                ],
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: avatarsList[index] == selectedAvatar
                                        ? MyColors.purple
                                        : MyColors.white,
                                    width: 4,
                                    style: BorderStyle.solid),
                                image: DecorationImage(
                                    image: NetworkImage(avatarsList[index])),
                              ),
                            ),
                          ),
                        );
                      }),
            )
          ],
        ),
        actions: [
          TextButton(
              onPressed: onResetClick,
              child: const Text16(text: 'Сбросить')),
          TextButton(
              onPressed: onSaveClick,
              child: const Text16(text: 'Сохранить'))
        ],
      ),
    );
  }
}
