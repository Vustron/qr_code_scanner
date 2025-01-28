import 'package:equatable/equatable.dart';

class QRCode extends Equatable {
  const QRCode({
    required this.id,
    required this.label,
    required this.rawValue,
    required this.scannedAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? scannedAt;

  factory QRCode.fromJson(Map<String, dynamic> json) {
    return QRCode(
      id: json['id'].toString(),
      label: json['label'] as String,
      rawValue: json['raw_value'] as String,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  final String id;
  final String label;
  final String rawValue;
  final DateTime scannedAt;
  final DateTime updatedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'label': label,
      'raw_value': rawValue,
      'scanned_at': scannedAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  QRCode copyWith({
    String? id,
    String? label,
    String? rawValue,
    DateTime? scannedAt,
    DateTime? updatedAt,
  }) {
    return QRCode(
      id: id ?? this.id,
      label: label ?? this.label,
      rawValue: rawValue ?? this.rawValue,
      scannedAt: scannedAt ?? this.scannedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        id,
        label,
        rawValue,
        scannedAt,
        updatedAt,
      ];
}
