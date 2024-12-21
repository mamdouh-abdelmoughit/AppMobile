import 'package:flutter/material.dart';
import 'package:moughit_app/pages/receipt_page.dart';
import 'package:moughit_app/pages/recipt_magasin_page.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../widgets/add_resident_dialog.dart';
import '../widgets/add_payment_dialog.dart';

class ResidentPage extends StatefulWidget {
  const ResidentPage({super.key});

  @override
  State<ResidentPage> createState() => _ResidentPageState();
}

class _ResidentPageState extends State<ResidentPage> {
  late final SupabaseService _supabaseService;
  List<Map<String, dynamic>> _residents = [];
  List<Map<String, dynamic>> _filteredResidents = []; // List to hold filtered results
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _supabaseService = SupabaseService(Supabase.instance.client);
    _loadResidents();
  }

  Future<void> _loadResidents() async {
    try {
      setState(() => _isLoading = true);
      final residents = await _supabaseService.getResidents();
      setState(() {
        _residents = residents;
        _filteredResidents = residents; // Initially, all residents are shown
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
      setState(() => _isLoading = false);
    }
  }

  // Method to filter residents based on the search query
  void _filterResidents(String query) {
    setState(() {
      _filteredResidents = _residents
          .where((resident) =>
              resident['numero'].toString().toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  Future<void> _showAddResidentDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddResidentDialog(),
    );

    if (result != null) {
      try {
        await _supabaseService.addResident(
          numero: result['numero'],
          type: result['type'],
          monthlyDue: result['monthlyDue'],
        );
        await _loadResidents();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Résident ajouté avec succès')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur: ${e.toString()}')),
          );
        }
      }
    }
  }

Future<void> _showAddPaymentDialog(String residentId, String numero, String residentType) async {
  final result = await showDialog<Map<String, dynamic>>(
    context: context,
    builder: (context) => AddPaymentDialog(
      residentId: residentId,
      residentNumero: numero,
      residentType: residentType,
    ),
  );

  if (result != null) {
    try {
      await _supabaseService.addPayment(
        residentId: residentId,
        amount: result['amount'],
        paymentDate: result['paymentDate'],
      );
      await _loadResidents();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Paiement ajouté avec succès')),
        );
      }

      // Navigate to the appropriate receipt page
      if (residentType == 'Magasin') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptPageMagasin(
              residentNumero: numero,
              montantParMois: result['amount'],
              residentType: residentType,
              paymentDate: result['paymentDate'],
            ),
          ),
        );
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ReceiptPage(
              residentNumero: numero,
              montantParMois: result['amount'],
              paymentDate: result['paymentDate'],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }
}


 // Method to delete a resident
  Future<void> _deleteResident(String residentId) async {
    try {
      await _supabaseService.deleteResident(residentId);
      await _loadResidents();  // Reload the resident list after deletion
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Résident supprimé avec succès')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${e.toString()}')),
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Résidents'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Entrez le numéro d\'appart/magasin',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: _filterResidents,
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SingleChildScrollView(
                      child: DataTable(
                        columns: const [
                          DataColumn(
                            label: Text(
                              'Numéro',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Type',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Montant Mensuel',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Montant Restant',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          DataColumn(
                            label: Text(
                              'Actions',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                        rows: _filteredResidents.map((resident) {
                          return DataRow(
                            cells: [
                              DataCell(Text(resident['numero'].toString())),
                              DataCell(Text(resident['type'])),
                              DataCell(Text('${resident['monthly_due'].toStringAsFixed(2)} DH')),
                              DataCell(
                                Text(
                                  '${resident['montant_restant'].toStringAsFixed(2)} DH',
                                  style: TextStyle(
                                    color: (resident['montant_restant'] as num) > 0
                                        ? Colors.red
                                        : Colors.green,
                                  ),
                                ),
                              ),
                              DataCell(
                                Row(
                                  children: [

                                  
                                IconButton(
                                  icon: const Icon(Icons.payment),
                                  onPressed: () => _showAddPaymentDialog(
                                    resident['id'],
                                    resident['numero'],
                                    resident['type'],
                                  ),
                                  tooltip: 'Ajouter un paiement',
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () => _deleteResident(resident['id']),
                                  tooltip: 'Supprimer le résident',
                                )
                                ],
                              ),
                              
                              ),
                            
                            ],
                            
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddResidentDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
