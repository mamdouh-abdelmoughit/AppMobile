import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../widgets/add_expense_dialog.dart';

class DepensePage extends StatefulWidget {
  const DepensePage({super.key});

  @override
  State<DepensePage> createState() => _DepensePageState();
}

class _DepensePageState extends State<DepensePage> {
  final SupabaseService _supabaseService = SupabaseService(Supabase.instance.client);
  List<Map<String, dynamic>> _expenses = [];
  Map<String, dynamic>? _selectedExpense;

  @override
  void initState() {
    super.initState();
    _fetchExpenses();
  }

  Future<void> _fetchExpenses() async {
    final expenses = await _supabaseService.getExpenses();
    setState(() {
      _expenses = expenses;
    });
  }

  Future<void> _showAddExpenseDialog() async {
    showDialog(
      context: context,
      builder: (context) {
        return AddExpenseDialog(
          onAdd: (String name, double amount, String description) async {
            await _supabaseService.addExpense(name: name, amount: amount, description: description);
            _fetchExpenses(); // Refresh the list after adding
          },
        );
      },
    );
  }

  Future<void> _deleteExpense(int id) async {
    await _supabaseService.deleteExpense(id);
    _fetchExpenses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des Dépenses'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _showAddExpenseDialog,
            child: const Text('Ajouter Dépense'),
          ),
          Expanded(
            child: _expenses.isEmpty
                ? const Center(
                    child: Text('Aucune dépense trouvée.'),
                  )
                : _selectedExpense != null
                    ? Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.arrow_back),
                                      onPressed: () {
                                        setState(() {
                                          _selectedExpense = null;
                                        });
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete),
                                      onPressed: () {
                                        _deleteExpense(_selectedExpense!['id']);
                                        setState(() {
                                          _selectedExpense = null;
                                        });
                                      },
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _selectedExpense!['name'],
                                  style: Theme.of(context).textTheme.headlineSmall,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Montant: ${_selectedExpense!['amount']} DH',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Description:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(height: 8),
                                Text(_selectedExpense!['description'] ?? 'Aucune description'),
                                const SizedBox(height: 16),
                                Text(
                                  'Date: ${DateTime.parse(_selectedExpense!['created_at']).toString().split('.')[0]}',
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _expenses.length,
                        itemBuilder: (context, index) {
                          final expense = _expenses[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: ListTile(
                              title: Text(expense['name']),
                              subtitle: Text('Montant: ${expense['amount']} DH'),
                              trailing: IconButton(
                                icon: const Icon(Icons.delete),
                                onPressed: () => _deleteExpense(expense['id']),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedExpense = expense;
                                });
                              },
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
