class OneYearReportListItem {
  final int id;
  final double sales;
  final double commissionReceived;
  final double cashInHand;
  final double cashInBank;
  final double landAndBuilding;
  final DateTime? createdAt;

  OneYearReportListItem({
    required this.id,
    required this.sales,
    required this.commissionReceived,
    required this.cashInHand,
    required this.cashInBank,
    required this.landAndBuilding,
    this.createdAt,
  });

  factory OneYearReportListItem.fromJson(Map<String, dynamic> json) {
    return OneYearReportListItem(
      id: int.tryParse(json['id'].toString()) ?? 0,
      sales: double.tryParse(json['sales'].toString()) ?? 0,
      commissionReceived:
      double.tryParse(json['commissionReceived'].toString()) ?? 0,
      cashInHand:
      double.tryParse(json['cashInHand'].toString()) ?? 0,
      cashInBank:
      double.tryParse(json['cashInBank'].toString()) ?? 0,
      landAndBuilding:
      double.tryParse(json['landAndBuilding'].toString()) ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}