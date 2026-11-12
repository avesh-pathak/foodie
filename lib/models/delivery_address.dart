enum AddressType { home, work, other }

extension AddressTypeLabel on AddressType {
  String get label {
    switch (this) {
      case AddressType.home:
        return 'Home';
      case AddressType.work:
        return 'Work';
      case AddressType.other:
        return 'Other';
    }
  }
}

class DeliveryAddress {
  const DeliveryAddress({
    required this.id,
    required this.label,
    required this.line1,
    required this.line2,
    required this.type,
    this.isDefault = false,
  });

  final String id;
  final String label;
  final String line1;
  final String line2;
  final AddressType type;
  final bool isDefault;

  String get oneLine => '$line1, $line2';

  DeliveryAddress copyWith({
    String? label,
    String? line1,
    String? line2,
    AddressType? type,
    bool? isDefault,
  }) {
    return DeliveryAddress(
      id: id,
      label: label ?? this.label,
      line1: line1 ?? this.line1,
      line2: line2 ?? this.line2,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
    );
  }
}
