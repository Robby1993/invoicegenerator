class Customer {
  final int? id;
  final String name;
  final String mobile;
  final String address;
  final String city;
  final String state;
  final String pincode;
  final String gstNumber;

  Customer({
    this.id,
    required this.name,
    required this.mobile,
    required this.address,
    required this.city,
    required this.state,
    required this.pincode,
    required this.gstNumber,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
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
      id: map['id'],
      name: map['name'],
      mobile: map['mobile'],
      address: map['address'],
      city: map['city'],
      state: map['state'],
      pincode: map['pincode'],
      gstNumber: map['gstNumber'],
    );
  }
}


extension CustomerCopy on Customer {
  Customer copyWith({int? id}) {
    return Customer(
      id: id ?? this.id,
      name: name,
      mobile: mobile,
      address: address,
      city: city,
      state: state,
      pincode: pincode,
      gstNumber: gstNumber,
    );
  }
}
