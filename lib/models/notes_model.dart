class Note {
  final String id;
  final String title;
  final String description;
  final List<String> fileUrls;
  final String fileType;

  Note({
    required this.id,
    required this.title,
    required this.description,
    required this.fileUrls,
    required this.fileType,
});
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      fileUrls: List<String>.from(json['file_urls'] ?? []),
      fileType: json['file_type'] ?? '',
    );
  }
}