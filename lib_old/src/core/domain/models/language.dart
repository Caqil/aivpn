class Language {
  Language({
    this.label,
    this.languageCode,
    this.countryCode,
  });

  String? label;
  String? languageCode;
  String? countryCode;
  factory Language.fromJson(Map<String, dynamic> json) => Language(
        label: json["label"],
        languageCode:
            json["language_code"],
        countryCode: json["country_code"],
      );

  Map<String, dynamic> toJson() => {
        "label": label,
        "language_code": languageCode,
        "country_code": countryCode,
      };
}
