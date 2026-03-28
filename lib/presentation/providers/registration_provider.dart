import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegistrationData {
  String fullName;
  String dob;
  String gender;
  String fatherName;
  String birthPlace;
  String address;
  String aadhaar;
  String phone;
  String nomineeName;
  String nomineeRelationship;
  String username;
  String pin;
  String password;

  RegistrationData({
    this.fullName = '',
    this.dob = '',
    this.gender = '',
    this.fatherName = '',
    this.birthPlace = '',
    this.address = '',
    this.aadhaar = '',
    this.phone = '',
    this.nomineeName = '',
    this.nomineeRelationship = '',
    this.username = '',
    this.pin = '',
    this.password = '',
  });

  RegistrationData copyWith({
    String? fullName,
    String? dob,
    String? gender,
    String? fatherName,
    String? birthPlace,
    String? address,
    String? aadhaar,
    String? phone,
    String? nomineeName,
    String? nomineeRelationship,
    String? username,
    String? pin,
    String? password,
  }) {
    return RegistrationData(
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      fatherName: fatherName ?? this.fatherName,
      birthPlace: birthPlace ?? this.birthPlace,
      address: address ?? this.address,
      aadhaar: aadhaar ?? this.aadhaar,
      phone: phone ?? this.phone,
      nomineeName: nomineeName ?? this.nomineeName,
      nomineeRelationship: nomineeRelationship ?? this.nomineeRelationship,
      username: username ?? this.username,
      pin: pin ?? this.pin,
      password: password ?? this.password,
    );
  }
}

class RegistrationNotifier extends StateNotifier<RegistrationData> {
  RegistrationNotifier() : super(RegistrationData());

  void updateStep1({
    String? fullName,
    String? dob,
    String? gender,
    String? fatherName,
    String? birthPlace,
  }) {
    state = state.copyWith(
      fullName: fullName,
      dob: dob,
      gender: gender,
      fatherName: fatherName,
      birthPlace: birthPlace,
    );
  }

  void updateStep2({String? address, String? aadhaar, String? phone}) {
    state = state.copyWith(address: address, aadhaar: aadhaar, phone: phone);
  }

  void updateStep3({String? nomineeName, String? nomineeRelationship}) {
    state = state.copyWith(
      nomineeName: nomineeName,
      nomineeRelationship: nomineeRelationship,
    );
  }

  void updateStep4({String? username, String? pin, String? password}) {
    state = state.copyWith(username: username, pin: pin, password: password);
  }

  void reset() {
    state = RegistrationData();
  }
}

final registrationProvider =
    StateNotifierProvider<RegistrationNotifier, RegistrationData>((ref) {
      return RegistrationNotifier();
    });
