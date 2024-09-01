import 'package:flutter_test/flutter_test.dart';
import 'package:weekplanner/models/week_template_name_model.dart';

void main() {
  final Map<String, dynamic> response = <String, dynamic>{
    'name': 'SkabelonUge',
    'templateId': 1
  };

  test('Should be able to instantiate from JSON', () {
    final WeekTemplateNameModel templateName =
        WeekTemplateNameModel.fromJson(response);

    expect(templateName.name, response['name']);
    expect(templateName.id, response['templateId']);
  });

  test('Should throw exception if JSON is null', () {
    expect(() => WeekTemplateNameModel.fromJson(null), throwsFormatException);
  });

  test('Should be able to serialize to JSON', () {
    final WeekTemplateNameModel templateName =
        WeekTemplateNameModel.fromJson(response);

    expect(templateName.toJson(), response);
  });
}
