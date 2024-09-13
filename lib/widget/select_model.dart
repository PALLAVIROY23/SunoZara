class SelectModel {
  String value;
  String text;
  @override
  String toString() {
    return '$value $text';
  }

  factory SelectModel.fromJson(dynamic json) {
    return SelectModel(
      json['value'].toString(),
      json['text'].toString(),
    );
  }
  Map<String, dynamic> toJson() => {
        'value': value,
        'text': text,
      };

  SelectModel(this.value, this.text);
}
