import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:weekplanner/http/http.dart';
import 'package:weekplanner/models/pictogram_model.dart';

/// Pictogram endpoints
class PictogramApi {
  /// Default constructor
  PictogramApi(this._http);

  final Http _http;

  /// Get all public pictograms available to the user (i.e the public pictograms
  /// and those owned by the user (PRIVATE) and his department (PROTECTED)).
  ///
  /// [query] The query string. pictograms are filtered based on this string
  /// if passed
  /// [pageSize] Number of pictograms per page
  /// [page] Page number
  Stream<List<PictogramModel>?> getAll(
      {String? query, required int page, required int pageSize}) {
    // TODO(boginw): move the support for queryParams to Http
    final Uri uri = Uri(queryParameters: <String, String>{
      'query': query!,
      'page': page.toString(),
      'pageSize': pageSize.toString(),
    });

    return _http.get(uri.toString()).map((Response res) {
      if (res.json['data'] is List) {
        return List<Map<String, dynamic>>.from(res.json['data'])
            .map((Map<String, dynamic> map) {
          return PictogramModel.fromJson(map);
        }).toList();
      } else {
        // TODO(boginw): throw appropriate error
        return null;
      }
    });
  }

  /// Read the pictogram with the specified id id and check if the user is
  /// authorized to see it.
  ///
  /// [id] Id of pictogram to get
  Stream<PictogramModel> get(int id) {
    return _http.get('/$id').map((Response res) {
      return PictogramModel.fromJson(res.json['data']);
    });
  }

  /// Create a new pictogram.
  ///
  /// [pictogram] Pictogram to create
  Stream<PictogramModel> create(PictogramModel pictogram) {
    return _http.post('/', pictogram.toJson()).map((Response res) {
      return PictogramModel.fromJson(res.json['data']);
    });
  }

  /// Update info of a GirafRest.Models.Pictogram pictogram.
  ///
  /// [pictogram] A Pictogram with all new information to update with. The Id
  /// found in this DTO is the target pictogram.
  Stream<PictogramModel> update(PictogramModel pictogram) {
    return _http
        .put('/${pictogram.id}', pictogram.toJson())
        .map((Response res) {
      return PictogramModel.fromJson(res.json['data']);
    });
  }

  /// Delete the pictogram with the specified id.
  ///
  /// [id] The id of the pictogram to delete.
  Stream<bool> delete(int id) {
    return _http.delete('/$id').map((Response res) {
      return res.success();
    });
  }

  /// Updates the [image] of a pictogram with the given [id]
  ///
  ///  [id] Id of the pictogram for which the image should be updated
  /// [image] List of Uint8 representing an image
  Stream<PictogramModel> updateImage(int id, Uint8List image) {
    return _http.put('/$id/image', image).map((Response res) {
      return PictogramModel.fromJson(res.json['data']);
    });
  }

  /// Reads the raw pictogram image. You are allowed to read all public
  /// pictograms as well as your own pictograms or any pictograms shared within
  /// the department
  ///
  /// [id] ID of the pictogram for which the image should be fetched
  Stream<Image> getImage(int id) {
    return _http.get('/$id/image/raw').map((Response res) {
      return Image.memory(res.response.bodyBytes);
    });
  }
}
