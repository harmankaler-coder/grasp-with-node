import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/course_model.dart';

class PdfService {
  static const storage = FlutterSecureStorage();

  static Future<void> saveAndOpenPdf(Course course) async {
    final pdf = await _generatePdf(course);
    final bytes = await pdf.save();

    String? userId = await storage.read(key: "userId");

    final baseDir = await getApplicationDocumentsDirectory();
    final userDir = Directory('${baseDir.path}/$userId');

    if (!await userDir.exists()) {
      await userDir.create(recursive: true);
    }

    final fileName =
        '${course.topic.replaceAll(RegExp(r'[^\w\s]+'), '_')}_CheatSheet.pdf';

    final file = File('${userDir.path}/$fileName');

    await file.writeAsBytes(bytes);

    await OpenFilex.open(file.path);
  }

  static Future<pw.Document> _generatePdf(Course course) async {
    final pdf = pw.Document();

    final PdfColor primaryColor = PdfColors.teal;
    final PdfColor accentColor = PdfColors.teal50;
    final PdfColor textColor = PdfColors.blueGrey900;

    final titleStyle = pw.TextStyle(
        fontSize: 26,
        fontWeight: pw.FontWeight.bold,
        color: PdfColors.white);

    final chapterHeaderStyle = pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: primaryColor);

    final pointStyle =
    pw.TextStyle(fontSize: 10, color: textColor, lineSpacing: 2.0);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(0),
        build: (pw.Context context) {
          return [
            pw.Container(
              padding: const pw.EdgeInsets.all(30),
              child: pw.Column(
                children: course.chapters.map((chapter) {
                  List<String> points = chapter.cheatSheet
                      .replaceAll(r'\n', '\n')
                      .split('\n')
                      .where((s) => s.trim().isNotEmpty)
                      .map((s) =>
                      s.trim().replaceAll(RegExp(r'^[-•*]\s*'), ''))
                      .toList();

                  if (points.isEmpty) return pw.Container();

                  return pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 25),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Container(
                          padding: const pw.EdgeInsets.symmetric(
                              vertical: 6, horizontal: 12),
                          decoration: pw.BoxDecoration(
                            color: accentColor,
                            borderRadius: const pw.BorderRadius.all(
                                pw.Radius.circular(4)),
                          ),
                          child: pw.Text(
                            chapter.title.toUpperCase(),
                            style: chapterHeaderStyle,
                          ),
                        ),
                        pw.SizedBox(height: 12),
                        ...points.map((point) {
                          return pw.Padding(
                            padding: const pw.EdgeInsets.only(
                                bottom: 8, left: 10),
                            child: pw.Row(
                              crossAxisAlignment:
                              pw.CrossAxisAlignment.start,
                              children: [
                                pw.Container(
                                  width: 6,
                                  height: 6,
                                  margin: const pw.EdgeInsets.only(
                                      top: 4, right: 10),
                                  decoration: pw.BoxDecoration(
                                    color: primaryColor,
                                    shape: pw.BoxShape.circle,
                                  ),
                                ),
                                pw.Expanded(
                                    child: pw.Text(point,
                                        style: pointStyle)),
                              ],
                            ),
                          );
                        }).toList(),
                        pw.SizedBox(height: 10),
                        pw.Divider(
                            color: PdfColors.grey300, thickness: 0.5),
                      ],
                    ),
                  );
                }).toList(),
              ),
            )
          ];
        },
      ),
    );
    return pdf;
  }
}