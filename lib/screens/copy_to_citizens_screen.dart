// ignore_for_file: lines_longer_than_80_chars

import 'package:flutter/material.dart';
import 'package:weekplanner/blocs/copy_weekplan_bloc.dart';
import 'package:weekplanner/di.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/app_bar_icons_enum.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/screens/copy_resolve_screen.dart';
import 'package:weekplanner/screens/weekplan_selector_screen.dart';
import 'package:weekplanner/widgets/citizen_avatar_widget.dart';
import 'package:weekplanner/widgets/giraf_3button_dialog.dart';
import 'package:weekplanner/widgets/giraf_app_bar_widget.dart';
import 'package:weekplanner/widgets/giraf_button_widget.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';
import 'package:weekplanner/widgets/giraf_notify_dialog.dart';

import '../routes.dart';
import '../style/custom_color.dart' as theme;

/// The screen to choose a citizen
class CopyToCitizensScreen extends StatelessWidget {
  /// <param name='model'>WeekModel that should be copied
  CopyToCitizensScreen(this._copiedWeekModelList, this._currentUser);

  final List<WeekModel> _copiedWeekModelList;
  final CopyWeekplanBloc _bloc = di.get<CopyWeekplanBloc>();
  final DisplayNameModel _currentUser;

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: screenSize.width,
        height: screenSize.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/login_screen_background_image.png'),
            fit: BoxFit.cover,
          ),
        ),
        // Creates a new Dialog
        child: Dialog(
          child: Scaffold(
            appBar: GirafAppBar(
              title: 'Vælg borger',
              appBarIcons: const <AppBarIcon, VoidCallback>{},
              key: UniqueKey(),
            ),
            body: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: <Widget>[
                  Container(
                      child: Expanded(child: _buildWeekplanGridview(context))),
                  Row(
                    children: <Widget>[
                      const Spacer(flex: 1),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          child: GirafButton(
                            key: const Key('CancelButton'),
                            onPressed: () {
                              Routes().pop(context);
                            },
                            icon: const ImageIcon(
                                AssetImage('assets/icons/cancel.png')),
                          ),
                        ),
                      ),
                      const Spacer(flex: 1),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                            child: GirafButton(
                                key: const Key('AcceptButton'),
                                onPressed: () async {
                                  await _bloc
                                      .numberOfConflictingUsers(
                                          _copiedWeekModelList,
                                          _currentUser,
                                          false)
                                      .then((int conflicts) {
                                    if (conflicts > 0) {
                                      if (_copiedWeekModelList.length == 1) {
                                        _showConflictDialog(
                                            context,
                                            conflicts,
                                            _bloc.getAllConflictingUsers(
                                                _currentUser,
                                                _copiedWeekModelList));
                                      } else {
                                        _showConflictDialogMultiplePlans(
                                            context,
                                            conflicts,
                                            _bloc.getAllConflictingUsers(
                                                _currentUser,
                                                _copiedWeekModelList));
                                      }
                                    } else {
                                      _bloc.copyWeekplan(_copiedWeekModelList,
                                          _currentUser, false);
                                      Routes().goHome(context);
                                      Routes().push(context,
                                          WeekplanSelectorScreen(_currentUser));
                                      _showCopySuccessDialog(context);
                                    }
                                  });
                                },
                                icon: const ImageIcon(
                                    AssetImage('assets/icons/accept.png')))),
                      ),
                      const Spacer(flex: 1),
                    ],
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekplanGridview(BuildContext context) {
    final bool portrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return StreamBuilder<List<DisplayNameModel>>(
        initialData: const <DisplayNameModel>[],
        stream: _bloc.citizen,
        builder: (BuildContext context,
            AsyncSnapshot<List<DisplayNameModel>> usersSnapshot) {
          if (usersSnapshot.data == null) {
            return Container();
          } else {
            return StreamBuilder<List<DisplayNameModel>>(
                stream: _bloc.markedUserModels,
                builder: (BuildContext context,
                    AsyncSnapshot<List<DisplayNameModel>> markedUsersSnapshot) {
                  return GridView.count(
                      crossAxisCount: portrait ? 2 : 4,
                      children:
                          usersSnapshot.data!.map((DisplayNameModel user) {
                        return _buildUserSelector(context, user,
                            markedUsersSnapshot.data!.contains(user));
                      }).toList());
                });
          }
        });
  }

  Widget _buildUserSelector(
      BuildContext context, DisplayNameModel user, bool isMarked) {
    final CitizenAvatar avatar = CitizenAvatar(
        displaynameModel: user,
        onPressed: () => _bloc.toggleMarkedUserModel(user));

    if (isMarked) {
      return Container(
          decoration: BoxDecoration(
            border: Border.all(color: theme.GirafColors.black, width: 10),
          ),
          child: avatar);
    } else {
      return avatar;
    }
  }

  ///Builds dialog box to fix conflicts for a single WeekPlan
  Future<Center?> _showConflictDialog(BuildContext context, int conflicts,
      Future<List<String>> futureUserList) async {
    final List<String> userList = (await futureUserList).toSet().toList();
    String userStringList = userList[0];
    for (int i = 1; i < userList.length - 1; i++) {
      userStringList += ', ${userList[i]}';
    }
    if (userList.length > 1) {
      userStringList += ' og ${userList[userList.length - 1]}';
    }

    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return Giraf3ButtonDialog(
            title: 'Håndter konflikt',
            description: userStringList.length < 500
                ? '${userList.length == 1 ? '' : 'Følgende borgere: '}'
                    '$userStringList har i alt $conflicts '
                    'konflikt${conflicts > 1 ? 'er' : ''}.'
                : '${userList.length}'
                    'antal borgere har i alt $conflicts konflikt${conflicts > 1 ? 'er' : ''}.',
            option1Text: 'Rediger',
            option1OnPressed: () {
              Routes().pop(context);
              Routes().push(
                  context,
                  CopyResolveScreen(
                    currentUser: _currentUser,
                    weekModel: _copiedWeekModelList[0],
                    copyBloc: _bloc,
                    forThisCitizen: false,
                  ));
            },
            option1Icon: const ImageIcon(AssetImage('assets/icons/copy.png')),
            option2Text: 'Overskriv',
            option2OnPressed: () {
              _bloc
                  .copyWeekplan(_copiedWeekModelList, _currentUser, false)
                  .then((_) {
                Routes().goHome(context);
                Routes().push(context, WeekplanSelectorScreen(_currentUser));
              });
            },
            option2Icon: const ImageIcon(AssetImage('assets/icons/copy.png')),
            key: UniqueKey(),
          );
        });
  }

  ///Builds dialog box to fix conflicts for multiple WeekPlans
  Future<Center?> _showConflictDialogMultiplePlans(BuildContext context,
      int conflicts, Future<List<String>> futureUserList) async {
    final List<String> userList = (await futureUserList).toSet().toList();
    String userStringList = userList[0];
    for (int i = 1; i < userList.length - 1; i++) {
      userStringList += ', ${userList[i]}';
    }
    if (userList.length > 1) {
      userStringList += ' og ${userList[userList.length - 1]}';
    }
    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return GirafConfirmDialog(
            title: 'Håndter konflikt',
            description: userStringList.length < 500
                ? '${userList.length == 1 ? '' : 'Følgende borgere: '}'
                    '$userStringList har i alt $conflicts '
                    'konflikt${conflicts > 1 ? 'er' : ''}.'
                : '${userList.length} '
                    'antal borgere har i alt $conflicts konflikt${conflicts > 1 ? 'er' : ''}.',
            confirmButtonText: 'Overskriv',
            confirmOnPressed: () {
              _bloc
                  .copyWeekplan(_copiedWeekModelList, _currentUser, false)
                  .then((_) {
                Routes().goHome(context);
                Routes().push(context, WeekplanSelectorScreen(_currentUser));
              });
            },
            confirmButtonIcon:
                const ImageIcon(AssetImage('assets/icons/copy.png')),
            key: UniqueKey(),
          );
        });
  }

  Future<Center?> _showCopySuccessDialog(BuildContext context) {
    return showDialog<Center>(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) {
          return const GirafNotifyDialog(
              title: 'Ugeplan kopieret',
              description: 'Ugeplanen blev kopieret til de valgte borgere',
              key: Key('OkaySuccessButton'));
        });
  }
}
