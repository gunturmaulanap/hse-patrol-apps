enum RiskLevel {
  immediate,
  within24Hours,
  within3Days,
  within2Weeks,
  unknown;

  factory RiskLevel.fromRaw(dynamic raw) {
    final normalized = raw?.toString().trim() ?? '';

    switch (normalized) {
      case '1':
        return RiskLevel.immediate;
      case '2':
        return RiskLevel.within24Hours;
      case '3':
        return RiskLevel.within3Days;
      case '4':
        return RiskLevel.within2Weeks;
      default:
        return RiskLevel.unknown;
    }
  }
}

extension RiskLevelX on RiskLevel {
  String get rawValue {
    return switch (this) {
      RiskLevel.immediate => '1',
      RiskLevel.within24Hours => '2',
      RiskLevel.within3Days => '3',
      RiskLevel.within2Weeks => '4',
      RiskLevel.unknown => '',
    };
  }

  String get label {
    return switch (this) {
      RiskLevel.immediate => 'Kurang dari 2 jam',
      RiskLevel.within24Hours => 'Kurang dari 24 jam',
      RiskLevel.within3Days => 'Kurang dari 3 hari',
      RiskLevel.within2Weeks => 'Kurang dari 2 minggu',
      RiskLevel.unknown => '-',
    };
  }
}
