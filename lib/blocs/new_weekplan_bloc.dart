// ignore_for_file: public_member_api_docs

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/bloc_base.dart';
import 'package:weekplanner/models/activity_model.dart';
import 'package:weekplanner/models/displayname_model.dart';
import 'package:weekplanner/models/enums/weekday_enum.dart';
import 'package:weekplanner/models/pictogram_model.dart';
import 'package:weekplanner/models/week_model.dart';
import 'package:weekplanner/models/week_name_model.dart';
import 'package:weekplanner/models/weekday_model.dart';
import 'package:weekplanner/routes.dart';
import 'package:weekplanner/widgets/giraf_confirm_dialog.dart';

/// New-Weekplan Business Logic Component.
class NewWeekplanBloc extends BlocBase {
  /// Constructor for [NewWeekplanBloc].
  /// The bloc contains sinks to handle when different inputs are entered and
  /// streams to tell if the inputs are valid.
  /// The bloc is also able to save the newly created weekplan.
  ///
  /// It is important that the bloc is initialized before use!
  /// This is done with the method [initialize].
  NewWeekplanBloc(this.weekApi);

  /// This is used to access the weekModel in the database
  @protected
  final Api weekApi;

  /// This field is used to get the userId. Accessed in
  /// [edit_weekplan_bloc].
  @protected
  DisplayNameModel? weekUser;

  /// This field controls the title input field
  @protected
  final rx_dart.BehaviorSubject<String?> titleController =
      rx_dart.BehaviorSubject<String?>();

  /// This field controls the year no input field
  @protected
  final rx_dart.BehaviorSubject<String?> yearController =
      rx_dart.BehaviorSubject<String?>();

  /// This field controls the week no input field
  @protected
  final rx_dart.BehaviorSubject<String?> weekNoController =
      rx_dart.BehaviorSubject<String?>();

  /// This field controls the pictogram input field
  @protected
  final rx_dart.BehaviorSubject<PictogramModel?> thumbnailController =
      rx_dart.BehaviorSubject<PictogramModel?>();

  /// Handles when the entered title is changed.
  Sink<String?> get onTitleChanged => titleController.sink;

  /// Handles when the entered year is changed.
  Sink<String?> get onYearChanged => yearController.sink;

  /// Handles when the entered week number is changed.
  Sink<String?> get onWeekNumberChanged => weekNoController.sink;

  /// Emits a [WeekNameModel] when it has a title, year, and week.
  /// If any input is invalid, emits null.
  Stream<WeekNameModel> get newWeekPlan => rx_dart.Rx.combineLatest4(
      allInputsAreValidStream,
      titleController.stream,
      yearController.stream,
      weekNoController.stream,
      _combineWeekNameModel);

  /// Handles when the thumbnail is changed.
  Sink<PictogramModel?> get onThumbnailChanged => thumbnailController.sink;

  /// Gives information about whether the entered title is valid.
  /// Values can be true (valid), false (invalid) and null (initial value).
  Stream<bool> get validTitleStream =>
      titleController.stream.transform(_titleValidation);

  /// Gives information about whether the entered year is valid.
  /// Values can be true (valid), false (invalid) and null (initial value).
  Stream<bool> get validYearStream =>
      yearController.stream.transform(_yearValidation);

  /// Gives information about whether the entered week number is valid.
  /// Values can be true (valid), false (invalid) and null (initial value).
  Stream<bool> get validWeekNumberStream =>
      weekNoController.stream.transform(_weekNumberValidation);

  /// Streams the chosen thumbnail.
  Stream<PictogramModel?> get thumbnailStream => thumbnailController.stream;

  /// Gives information about whether all inputs are valid.
  Stream<bool> get allInputsAreValidStream =>
      rx_dart.Rx.combineLatest4<bool, bool, bool, PictogramModel?, bool>(
              validTitleStream,
              validYearStream,
              validWeekNumberStream,
              thumbnailStream,
              _isAllInputValid)
          .asBroadcastStream();

  /// Resets the bloc if it already contains information from the last time it
  /// was used. Switches user to the one provided.
  /// This method should always be called before using the bloc.
  void initialize(DisplayNameModel user) {
    if (weekUser != null) {
      resetBloc();
    }
    weekUser = user;
  }

  /// Saves the entered information to the database.
  Future<WeekModel> saveWeekplan({
    required BuildContext? screenContext,
    required Stream<List<WeekNameModel>?> existingWeekPlans,
  }) async {
    if (weekUser == null) {
      // ignore: null_argument_to_non_null_type
      return Future<WeekModel>.value(null);
    }

    final String? _title = titleController.value;
    final int _year = int.parse(yearController.value!);
    final int _weekNumber = int.parse(weekNoController.value!);
    final PictogramModel? _thumbnail = thumbnailController.value;

    final WeekModel _weekModel = WeekModel(
        thumbnail: _thumbnail,
        name: _title,
        weekYear: _year,
        weekNumber: _weekNumber,
        days: <WeekdayModel>[
          WeekdayModel(day: Weekday.Monday, activities: <ActivityModel>[]),
          WeekdayModel(day: Weekday.Tuesday, activities: <ActivityModel>[]),
          WeekdayModel(day: Weekday.Wednesday, activities: <ActivityModel>[]),
          WeekdayModel(day: Weekday.Thursday, activities: <ActivityModel>[]),
          WeekdayModel(day: Weekday.Friday, activities: <ActivityModel>[]),
          WeekdayModel(day: Weekday.Saturday, activities: <ActivityModel>[]),
          WeekdayModel(day: Weekday.Sunday, activities: <ActivityModel>[])
        ]);

    bool doOverwrite = true;

    final bool hasExistingMatch = await hasExisitingMatchingWeekplan(
        existingWeekPlans: existingWeekPlans,
        year: _year,
        weekNumber: _weekNumber);

    // If there is a match, ask the user if we should overwrite.
    if (hasExistingMatch) {
      doOverwrite =
          await displayOverwriteDialog(screenContext!, _weekNumber, _year);
    }

    final Completer<WeekModel> saveCompleter = Completer<WeekModel>();
    if (doOverwrite) {
      weekApi.week
          .update(weekUser!.id!, _weekModel.weekYear, _weekModel.weekNumber,
              _weekModel)
          .take(1)
          .listen(saveCompleter.complete);
    } else {
      // ignore: null_argument_to_non_null_type
      saveCompleter.complete(null);
    }

    return saveCompleter.future;
  }

  /// Returns a [Future] that resolves to true if there is a matching week plan
  /// with the same year and week number.
  Future<bool> hasExisitingMatchingWeekplan({
    required Stream<List<WeekNameModel>?> existingWeekPlans,
    required int year,
    required int weekNumber,
  }) {
    final Completer<bool> matchCompleter = Completer<bool>();

    bool hasMatch = false;

    existingWeekPlans.take(1).listen((List<WeekNameModel>? existingPlans) {
      for (WeekNameModel? existingPlan in existingPlans!) {
        if (existingPlan!.weekYear == year &&
            existingPlan.weekNumber == weekNumber) {
          hasMatch = true;
        }
      }

      matchCompleter.complete(hasMatch);
    });

    return matchCompleter.future;
  }

  /// Display the overwrite dialog and resolve the [Future]
  /// to true if the user wants to overwrite.
  Future<bool> displayOverwriteDialog(
      BuildContext context, int weekNumber, int year) {
    final Completer<bool> dialogCompleter = Completer<bool>();
    showDialog<Center>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          // A confirmation dialog is shown to stop the timer.
          return GirafConfirmDialog(
            key: const Key('OverwriteEditDialogKey'),
            title: 'Overskriv ugeplan',
            description: 'Ugeplanen (uge: $weekNumber'
                ', år: $year) eksisterer '
                'allerede. Vil du overskrive denne ugeplan?',
            confirmButtonText: 'Okay',
            confirmButtonIcon:
                const ImageIcon(AssetImage('assets/icons/accept.png')),
            confirmOnPressed: () {
              dialogCompleter.complete(true);
              Routes().pop(context);
            },
            cancelOnPressed: () {
              dialogCompleter.complete(false);
            },
          );
        });

    return dialogCompleter.future;
  }

  // Resets the bloc to its default values.
  // The bloc should be reset after each use.
  void resetBloc() {
    weekUser = null;
    titleController.sink.add(null);
    yearController.sink.add(null);
    weekNoController.sink.add(null);
    thumbnailController.sink.add(null);
  }

  WeekNameModel _combineWeekNameModel(
      bool isValid, String? name, String? year, String? week) {
    // if (!isValid) {
    //   return null;
    // }
    return WeekNameModel(
        name: name, weekYear: int.parse(year!), weekNumber: int.parse(week!));
  }

  bool _isAllInputValid(
      bool title, bool year, bool weekNumber, PictogramModel? thumbnail) {
    return title == true &&
        year == true &&
        weekNumber == true &&
        thumbnail != null;
  }

  final StreamTransformer<String?, bool> _titleValidation =
      StreamTransformer<String?, bool>.fromHandlers(
          handleData: (String? input, EventSink<bool> sink) {
    if (input == null) {
      sink.add(false);
    } else {
      sink.add(input.trim().isNotEmpty);
    }
  });

  final StreamTransformer<String?, bool> _yearValidation =
      StreamTransformer<String?, bool>.fromHandlers(
          handleData: (String? input, EventSink<bool> sink) {
    if (input == null) {
      sink.add(false);
    } else {
      final int? year = int.tryParse(input);
      sink.add(year != null && year >= 1000 && year <= 9999);
    }
  });

  final StreamTransformer<String?, bool> _weekNumberValidation =
      StreamTransformer<String?, bool>.fromHandlers(
          handleData: (String? input, EventSink<bool> sink) {
    if (input == null) {
      sink.add(false);
    } else {
      final int? weekNumber = int.tryParse(input);
      sink.add(weekNumber != null && weekNumber >= 1 && weekNumber <= 53);
    }
  });

  @override
  void dispose() {
    titleController.close();
    yearController.close();
    weekNoController.close();
    thumbnailController.close();
  }
}
