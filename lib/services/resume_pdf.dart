import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'resume_data.dart';

/// The preview and download both use this single A4 document.
Future<Uint8List> buildResumePdf(ResumeData data) async {
  final doc = pw.Document(title: 'Currículo - ${data.profile.name}', author: data.profile.name);
  final navy = PdfColor.fromHex('#203F68');
  final rail = PdfColor.fromHex('#E4E9E9');
  final text = PdfColor.fromHex('#303638');
  final sections = data.sections.entries.where((e) => e.value.isNotEmpty).toList();
  pw.Widget heading(String title, {bool divider = true}) => pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      if (divider) pw.Container(height: 1.6, color: rail, margin: const pw.EdgeInsets.only(top: 16, bottom: 24)),
      pw.Row(children: [
        pw.SvgImage(width: 13, height: 13, svg: '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><path fill="#303638" d="M2 3h6l2 2 2-2h6v14h-6l-2 2-2-2H2z"/><path stroke="white" stroke-width="1" d="M10 6v10"/></svg>'),
        pw.SizedBox(width: 6),
        pw.Expanded(child: pw.Text(title, style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, color: text))),
      ]),
      pw.SizedBox(height: 17),
    ],
  );
  pw.Widget entry(String value, bool emphasize) {
    final lines = value.trim().split('\n');
    return pw.Container(padding: const pw.EdgeInsets.only(bottom: 12), child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(emphasize ? lines.first.toUpperCase() : lines.first,
          style: pw.TextStyle(fontSize: 10.5, fontWeight: emphasize ? pw.FontWeight.bold : pw.FontWeight.normal, color: text, lineSpacing: 1.4)),
        for (final line in lines.skip(1))
          pw.Text(line, style: pw.TextStyle(fontSize: 10, color: text, lineSpacing: 1.4)),
      ],
    ));
  }
  doc.addPage(pw.MultiPage(
    pageTheme: pw.PageTheme(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.fromLTRB(218, 24, 28, 40),
      buildBackground: (context) => pw.FullPage(ignoreMargins: true, child: pw.Stack(children: [
        pw.Positioned(left: 24, top: context.pageNumber == 1 ? 198 : 24, bottom: 40, child: pw.Container(width: 176, color: rail)),
        if (context.pageNumber == 1)
          pw.Positioned(left: 24, right: 24, top: 24, child: pw.Container(height: 174, color: navy)),
      ])),
    ),
    maxPages: 100,
    footer: (context) => pw.Align(alignment: pw.Alignment.centerRight,
      child: pw.Padding(padding: const pw.EdgeInsets.only(top: 10), child: pw.Text('${context.pageNumber}', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)))),
    build: (_) => [
      pw.Container(height: 174, alignment: pw.Alignment.centerLeft, padding: const pw.EdgeInsets.only(left: 2, right: 12), child: pw.Column(
        mainAxisAlignment: pw.MainAxisAlignment.center,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text('PRIMEIRO PASSO', style: const pw.TextStyle(fontSize: 8, color: PdfColors.white)),
          pw.SizedBox(height: 15),
          pw.Text(data.profile.name.toUpperCase(), style: pw.TextStyle(fontSize: 19, fontWeight: pw.FontWeight.bold, color: PdfColors.white)),
          pw.SizedBox(height: 10),
          if (data.field('profession').isNotEmpty) pw.Text('PROFISSÃO: ${data.field('profession').toUpperCase()}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.white)),
          if (data.profile.currentRole.isNotEmpty) pw.Text('ATIVIDADE ATUAL: ${data.profile.currentRole.toUpperCase()}', style: const pw.TextStyle(fontSize: 10, color: PdfColors.white)),
        ],
      )),
      pw.SizedBox(height: 28),
      for (var i = 0; i < sections.length; i++) ...[
        pw.Header(level: 1, decoration: const pw.BoxDecoration(), margin: pw.EdgeInsets.zero,
          child: heading(sections[i].key, divider: i > 0)),
        for (final value in sections[i].value)
          entry(value, ['FORMAÇÃO','CURSOS','CERTIFICAÇÕES','EXPERIÊNCIAS','MEDALHAS DIGITAIS'].contains(sections[i].key)),
      ],
      if (data.contacts.isNotEmpty) ...[
        pw.Header(level: 1, decoration: const pw.BoxDecoration(), margin: pw.EdgeInsets.zero, child: heading('CONTATO')),
        for (final e in data.contacts.entries)
          pw.Padding(padding: const pw.EdgeInsets.only(bottom: 10), child: pw.RichText(text: pw.TextSpan(children: [
            pw.TextSpan(text: '${e.key}: ', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            pw.TextSpan(text: e.value),
          ], style: pw.TextStyle(fontSize: 9.5, color: text)))),
      ],
      pw.Container(height: 1.6, color: rail, margin: const pw.EdgeInsets.only(top: 24, bottom: 16)),
      pw.Text('Currículo gerado pelo Primeiro Passo. Informações fornecidas pela pessoa titular.', style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey600)),
    ],
  ));
  return doc.save();
}
