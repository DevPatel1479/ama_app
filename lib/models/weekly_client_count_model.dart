class WeeklyClientCountModel {
  final bool success;
  final TotalClientsByWeek totalClientsByWeek;

  WeeklyClientCountModel({
    required this.success,
    required this.totalClientsByWeek,
  });

  factory WeeklyClientCountModel.fromJson(Map<String, dynamic> json) {
    return WeeklyClientCountModel(
      success: json['success'] ?? false,
      totalClientsByWeek: TotalClientsByWeek.fromJson(
        json['total_clients_by_week'] ?? {},
      ),
    );
  }
}

class TotalClientsByWeek {
  final int firstWeek;
  final int secondWeek;
  final int thirdWeek;
  final int fourthWeek;

  TotalClientsByWeek({
    required this.firstWeek,
    required this.secondWeek,
    required this.thirdWeek,
    required this.fourthWeek,
  });

  factory TotalClientsByWeek.fromJson(Map<String, dynamic> json) {
    return TotalClientsByWeek(
      firstWeek: json['first_week'] ?? 0,
      secondWeek: json['second_week'] ?? 0,
      thirdWeek: json['third_week'] ?? 0,
      fourthWeek: json['fourth_week'] ?? 0,
    );
  }

  Map<String, int> toJson() {
    return {
      'first_week': firstWeek,
      'second_week': secondWeek,
      'third_week': thirdWeek,
      'fourth_week': fourthWeek,
    };
  }
}
