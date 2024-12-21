import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReceiptPage extends StatefulWidget {
  final String residentNumero;
  final double montantParMois;
  final DateTime paymentDate;

  const ReceiptPage({
    super.key,
    required this.residentNumero,
    required this.montantParMois,
    required this.paymentDate,
  });

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final _nameController = TextEditingController();
  final _monthsController = TextEditingController();

  Future<void> _generateReceipt() async {
    if (_nameController.text.isEmpty || _monthsController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Remplissez tous les champs')),
      );
      return;
    }

    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a5,
        build: (pw.Context context) {
          return pw.Container(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('N° ${widget.residentNumero}', style: pw.TextStyle(fontSize: 14)),
                    pw.Text('B.P.DH ${widget.montantParMois}', style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Reçu', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Text('Reçu de M. '),
                    pw.Text(_nameController.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Text('La somme: '),
                    pw.Text('${widget.montantParMois} DH',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Text('Pour: '),
                    pw.Text(_monthsController.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Le: ${widget.paymentDate.toString().split(' ')[0]}'),
                    pw.Text('Signature: ________________'),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save PDF to file
    final output = await getExternalStorageDirectory(); // Get external storage for Android
    if (output == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not access storage directory')),
      );
      return;
    }

    final fileName = "receipt_${widget.residentNumero}_${DateTime.now().millisecondsSinceEpoch}.pdf";
    final file = File("${output.path}/$fileName");
    await file.writeAsBytes(await pdf.save());

    // Show dialog with file location and options
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('PDF Generated Successfully'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('File saved at:'),
              const SizedBox(height: 8),
              Text(file.path, style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Share.shareFiles([file.path], text: 'Receipt PDF');
              },
              child: const Text('Share PDF'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('genere le recu'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Display auto-filled information
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('numero d\'appartement/magasin: ${widget.residentNumero}'),
                      Text('Montant par mois: ${widget.montantParMois} DH'),
                      Text('Date: ${widget.paymentDate.toString().split(' ')[0]}'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              // Manual input fields
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'nom du proprietaire',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _monthsController,
                decoration: const InputDecoration(
                  labelText: 'mois du paiement',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _generateReceipt,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Generate PDF Receipt'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
