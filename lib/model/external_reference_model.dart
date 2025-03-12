class ExternalReferenceModel {
  final String declarationOfWork;

  ExternalReferenceModel({
    required this.declarationOfWork
  });

  factory ExternalReferenceModel.fromJson(Map<String, dynamic> json) {
    return ExternalReferenceModel(
      declarationOfWork: json['declarationOfWork']
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'declarationOfWork': declarationOfWork,
    };
  }
}