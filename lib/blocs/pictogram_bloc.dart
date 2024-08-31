import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:rxdart/rxdart.dart' as rx_dart;
import 'package:weekplanner/api/api.dart';
import 'package:weekplanner/blocs/bloc_base.dart';
import 'package:weekplanner/models/pictogram_model.dart';

/// For how long the debouncer should wait
const int _debounceTime = 250;
const int _timeoutTime = 10000;

/// Amount of pictograms per page
const int pageSize = 24;

/// Pictogram Business Logic Component
class PictogramBloc extends BlocBase {
  /// Pictogram Business Logic Component
  ///
  /// Gives the ability to search for pictograms and await the results.
  PictogramBloc(this._api) {
    // Listens for if view is scrolled to the bottom
    sc.addListener(() {
      if (sc.position.pixels >= sc.position.maxScrollExtent) {
        extendSearch();
      }
    });
  }

  /// This stream is where all results from searching for pictograms are put in.
  ///
  /// The null value is used as a way to communicate loading. That is, if you
  /// receive null from this stream, you know to discard your previous results
  /// and display a loading indicator
  Stream<List<PictogramModel>?> get pictograms => _pictograms.stream;

  /// This is the pictograms received from the latest search function call.
  ///
  /// Is extended on extendSearch function call.
  List<PictogramModel> latestPictograms = <PictogramModel>[];

  /// This is the query string specified at the latest search.
  late String? latestQuery;

  /// This is the page number incrementing on every call to extendSearch.
  int latestPage = 1;

  /// The scroll controller used in scrollViews, to notify bottom-hits.
  ScrollController sc = ScrollController();

  /// Boolean used to specify if currently fetching pictograms from server.
  bool loadingPictograms = false;

  /// Boolean used to specify if more pictograms are able to be loaded.
  bool reachedLastPictogram = false;

  final rx_dart.BehaviorSubject<List<PictogramModel>?> _pictograms =
      rx_dart.BehaviorSubject<List<PictogramModel>?>();

  final Api _api;
  Timer? _debounceTimer;

  /// Initializes a search for [query].
  ///
  /// This does not accept empty strings.
  ///
  /// This function is debounced, so calling it twice, will cancel the first
  /// call, and replace it with the second. Waiting over 250ms will without any
  /// calls with execute the waiting search.
  ///
  /// The results are published in [pictograms].
  void search(String query) {
    //ensures that it always shows the first pictograms in the database
    latestPage = 1;

    loadingPictograms = true;
    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    _pictograms.add(null);
    late List<PictogramModel>? _resultPlaceholder;
    _debounceTimer = Timer(const Duration(milliseconds: _debounceTime), () {
      //Timer for sending an error if getting pictogram results takes too long

      Timer(const Duration(milliseconds: _timeoutTime), () {
        if (_resultPlaceholder == null || _resultPlaceholder!.isEmpty) {
          _pictograms.addError('Søgningen gav ingen resultater. '
              'Tjek internetforbindelsen.');
        }
      });
      _api.pictogram
          .getAll(page: latestPage, pageSize: pageSize, query: query)
          .listen((List<PictogramModel>? results) {
        _resultPlaceholder = results;
        latestPictograms = _resultPlaceholder!;
        latestQuery = query;
        latestPage = 1;
        reachedLastPictogram = false;
        loadingPictograms = false;
        _pictograms.add(_resultPlaceholder!);
      });
    });
  }

  /// Extends the previous search with additional pictograms
  ///
  /// The results are published in [pictograms].
  void extendSearch() {
    if (reachedLastPictogram || latestQuery == null) {
      return;
    }

    if (_debounceTimer != null) {
      _debounceTimer!.cancel();
    }

    loadingPictograms = true;
    // Update view with updated loadingPictogram value.
    _pictograms.add(latestPictograms);
    _debounceTimer = Timer(const Duration(milliseconds: _debounceTime), () {
      _api.pictogram
          .getAll(page: ++latestPage, pageSize: pageSize, query: latestQuery!)
          .listen((List<PictogramModel>? results) {
        if (results == null || results.isEmpty) {
          reachedLastPictogram = true;
        } else {
          latestPictograms.addAll(results);
        }
        loadingPictograms = false;
        // Update view with latest pictograms and loadingPictogram value.
        _pictograms.add(latestPictograms);
      });
    });
  }

  ///
  /// Deletes a chosen pictogram
  ///
  void delete(PictogramModel pm) {
    _api.pictogram.delete(pm.id!);
  }

  @override
  void dispose() {
    _pictograms.close();
    sc.dispose();
  }
}
