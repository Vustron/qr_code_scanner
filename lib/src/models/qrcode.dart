import 'package:equatable/equatable.dart';

class QRCode extends Equatable {
  const QRCode({
    required this.id,
    required this.rawValue,
    required this.scannedAt,
  });

  factory QRCode.fromJson(Map<String, dynamic> json) {
    return QRCode(
      id: json['id'].toString(),
      rawValue: json['raw_value'] as String,
      scannedAt: DateTime.parse(json['scanned_at'] as String),
    );
  }

  final String id;
  final String rawValue;
  final DateTime scannedAt;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'raw_value': rawValue,
      'scanned_at': scannedAt.toIso8601String(),
    };
  }

  QRCode copyWith({
    String? id,
    String? rawValue,
    DateTime? scannedAt,
  }) {
    return QRCode(
      id: id ?? this.id,
      rawValue: rawValue ?? this.rawValue,
      scannedAt: scannedAt ?? this.scannedAt,
    );
  }

  @override
  List<Object?> get props => <Object?>[id, rawValue, scannedAt];
}
