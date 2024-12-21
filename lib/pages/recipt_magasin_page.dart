import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ReceiptPageMagasin extends StatefulWidget {
  final String residentNumero;
  final double montantParMois;
  final String residentType;
  final DateTime paymentDate; // Added paymentDate here

  const ReceiptPageMagasin({
    super.key,
    required this.residentNumero,
    required this.montantParMois,
    required this.residentType,
    required this.paymentDate, // Initialize it here
  });

  @override
  State<ReceiptPageMagasin> createState() => _ReceiptPageMagasinState();
}

class _ReceiptPageMagasinState extends State<ReceiptPageMagasin> {
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final _nameController = TextEditingController(); // Controller for the name input

  Future<void> _generateReceipt() async {
    if (_startDateController.text.isEmpty || _endDateController.text.isEmpty || _nameController.text.isEmpty) {
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
                    pw.Text('${widget.montantParMois} DH', style: pw.TextStyle(fontSize: 14)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Text('Reçu de loyer', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
                pw.SizedBox(height: 20),
                pw.Row(
                  children: [
                    pw.Text('Pour le local situé à: '),
                    pw.Text(widget.residentType, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Text('Qui commence le: '),
                    pw.Text(_startDateController.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Text('Et se termine le: '),
                    pw.Text(_endDateController.text, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  children: [
                    pw.Text('Date de paiement: '), // Display paymentDate
                    pw.Text(widget.paymentDate.toString(), style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Text('Sous toutes réserves légales :', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                pw.Bullet(text: 'Ce reçu ne confère aucun droit au locataire en cas de litige.'),
                pw.Bullet(text: 'Le locataire doit conserver ce reçu pour toute vérification.'),
                pw.Bullet(text: 'En cas de retard, le locataire sera en violation du contrat.'),
                pw.SizedBox(height: 20),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
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
        title: const Text('Générer le reçu de loyer'),
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
                      Text('N°: ${widget.residentNumero}'),
                      Text('Montant par mois: ${widget.montantParMois} DH'),
                      Text('Type de local: ${widget.residentType}'),
                      Text('Date de paiement: ${widget.paymentDate}'), // Display paymentDate here
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Manual input fields
              TextField(
                controller: _startDateController,
                decoration: const InputDecoration(
                  labelText: 'Date de début',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _endDateController,
                decoration: const InputDecoration(
                  labelText: 'Date de fin',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: _generateReceipt,
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('Générer le reçu en PDF'),
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
