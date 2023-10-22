// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class ThemeModel {
  int id;
  String seed_color;
  String primary_color;
  String secondary_color;
  String tertiary_color;
  ThemeModel({
    required this.id,
    required this.seed_color,
    required this.primary_color,
    required this.secondary_color,
    required this.tertiary_color,
  });

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'seed_color': seed_color,
      'primary_color': primary_color,
      'secondary_color': secondary_color,
      'tertiary_color': tertiary_color,
    };
  }

  factory ThemeModel.fromMap(Map<String, dynamic> map) {
    return ThemeModel(
      id: map['id'] as int,
      seed_color: map['seed_color'] as String,
      primary_color: map['primary_color'] as String,
      secondary_color: map['secondary_color'] as String,
      tertiary_color: map['tertiary_color'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ThemeModel.fromJson(String source) =>
      ThemeModel.fromMap(json.decode(source) as Map<String, dynamic>);
}
