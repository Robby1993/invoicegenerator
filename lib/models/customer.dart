class Customer {
  final String name;
  final String mobile;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String gstNumber;

  Customer({
    required this.name,
    required this.mobile,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    this.gstNumber = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'mobile': mobile,
      'address': address,
      'city': city,
      'state': state,
      'pincode': pincode,
      'gstNumber': gstNumber,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      name: map['name'],
      mobile: map['mobile'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      pincode: map['pincode'],
      gstNumber: map['gstNumber'] ?? '',
    );
  }
}
