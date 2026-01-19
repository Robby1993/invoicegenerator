class CompanyConfig {
  // Company Information
  static const String companyName = 'MAHAVEER CHEM';
  static const String companyNameShort = 'MC';
  static const String tagline = 'Dealing in : Chemicals Minerals Pigments all Plastic Raw Materials.';

  // Contact Details
  static const String mobile1 = '9892005301';
  static const String mobile2 = '9594070924';

  // Address
  static const String address = '219/6, Road No.14, Jawahar Nagar, Goregoan (W), Mumbai-400064.';
  static const String city = 'Mumbai';
  static const String state = 'Maharashtra';
  static const String pincode = '400064';

  // GST Details
  static const String gstin = '27BRKPS2085RIZR';

  // Bank Details
  static const String bankName = 'Mangal Co. Operative Bank';
  static const String bankBranch = 'BRANCH: Goregoan West';
  static const String accountNumber = 'AC NO: 001110042006986';
  static const String ifscCode = 'IFSC Code: IBKL0691M01';

  // Invoice Settings
  static const String invoicePrefix = 'INV';
  static const String blessingText = 'Namo Namh Shree Guru Nemi Suriye';
  static const String proprietorName = 'Proprietor KHYATI KEVAL DOSHI.';

  // Terms and Conditions
  static const List<String> termsAndConditions = [
    '1. Subject to Mumbai Jurisdiction',
    '2. Our reponsibility ceases as soon as the goods leave our premises.',
    '3. Goods once sold will not be taken back. E.& O.E.',
    '4. Priscribed sales tax declaration will be given.',
  ];

  // Tax Rates (can be modified as needed)
  static const double defaultIGST = 18.0;
  static const double defaultCGST = 9.0;
  static const double defaultSGST = 9.0;

  // Helper methods
  static String getFormattedMobile1() => 'Mo. $mobile1';
  static String getFormattedMobile2() => mobile2;
  static String getFullAddress() => address;
  static String getGSTIN() => 'GSTIN : $gstin';
  static String getAccountDetails() => 'Ac no : $accountNumber';
  static String getIFSCDetails() => 'IFSC Code : $ifscCode';
  static String getCompanySignature() => 'For, $companyName';
}