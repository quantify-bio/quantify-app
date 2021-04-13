class Training {
  final String uid;
  Training({this.uid});
}

class TrainingData {
  String trainingid;
  String name;
  String description;
  DateTime date;
  Duration duration;
  int intensity;

  TrainingData({
    this.trainingid,
    this.name,
    this.description,
    this.date,
    this.duration,
    this.intensity,
  });
}
