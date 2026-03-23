class GstCalculator {
  static const double currentGoldGstRate = 0.03; // 3%
  static const double currentSilverGstRate = 0.03; // 3%
  static const double makingChargesGstRate = 0.05; // 5% depending on rules, sometimes 18%

  static double calculateGst(double baseAmount, double rate) {
    return baseAmount * rate;
  }

  static double calculateTotalAmount(double baseAmount, double rate) {
    return baseAmount + calculateGst(baseAmount, rate);
  }

  static Map<String, double> getDetailedBreakdown({
    required double baseAmount,
    required double rate,
  }) {
    final gst = calculateGst(baseAmount, rate);
    return {
      'base_amount': baseAmount,
      'gst_amount': gst,
      'cgst_amount': gst / 2,
      'sgst_amount': gst / 2,
      'total_amount': baseAmount + gst,
    };
  }
}
