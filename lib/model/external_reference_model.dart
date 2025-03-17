class ExternalReferenceModel {
  final String? declarationOfWork;

  ExternalReferenceModel({
    required this.declarationOfWork
  });

  factory ExternalReferenceModel.fromJson(Map<String, dynamic> json) {
    return ExternalReferenceModel(
      declarationOfWork: json['externalReference']?['declarationOfWork'] as String?
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'declarationOfWork': [declarationOfWork],
    };
  }
}