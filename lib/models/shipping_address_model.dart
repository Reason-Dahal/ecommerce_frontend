class ShippingAddressModel {
  final String city;
  final int postalCode;
  final int phone;

  ShippingAddressModel({
    required this.city,
    required this.postalCode,
    required this.phone,
  });

  factory ShippingAddressModel.fromJson(Map<String, dynamic> json) {
    return ShippingAddressModel(
      city: json['city'] ?? '',
      postalCode: json['postalCode'] ?? 0,
      phone: json['phone'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'city': city, 'postalCode': postalCode, 'phone': phone};
  }
}
