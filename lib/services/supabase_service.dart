import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client;

  SupabaseService(this.client);

  Future<List<Map<String, dynamic>>> getResidents() async {
    final response = await client
        .from('residents')
        .select('''
        *,
        payments (
          month,
          year,
          amount_paid,
          payment_date
        )
      ''')
        .order('numero');
  
    List<Map<String, dynamic>> residents = List<Map<String, dynamic>>.from(response);
  
    // Get current date for comparison
    DateTime now = DateTime.now();
    int currentMonth = now.month;
    int currentYear = now.year;

    // Calculate remaining amount for each resident
    return residents.map((resident) {
      double monthlyDue = (resident['monthly_due'] ?? 0).toDouble();
      List<Map<String, dynamic>> payments = List<Map<String, dynamic>>.from(resident['payments'] ?? []);

      // Get registration date and calculate the number of months since registration
      DateTime registrationDate = DateTime.parse(resident['created_at']);
      int monthsDiff = (currentYear - registrationDate.year) * 12 + (currentMonth - registrationDate.month);

      // Calculate total due amount up to the current date
      double totalDue = monthlyDue * monthsDiff;

      // Calculate the total amount already paid
      double totalPaid = payments.fold(0.0, (sum, payment) {
        // Check if the payment corresponds to a month before or equal to the current month
        if (payment['year'] < currentYear ||
            (payment['year'] == currentYear && payment['month'] <= currentMonth)) {
          return sum + (payment['amount_paid'] ?? 0).toDouble();
        }
        return sum;
      });

      // Calculate remaining amount
      double montantRestant = totalDue - totalPaid;

      return {
        ...resident,
        'montant_restant': montantRestant,
      };

    }).toList();
  }

  Future<void> addResident({
    required String numero,
    required String type,
    required double monthlyDue,
  }) async {
    await client.from('residents').insert({
      'numero': numero,
      'type': type,
      'monthly_due': monthlyDue,
    });
  }
  Future <void> deleteResident(String id) async {
    try{
      await client.from('residents').delete().eq('id', id);
    }catch(e){
      debugPrint('Error deleting resident: $e');
      rethrow;
    }
    
  }

  Future<void> addPayment({
    required String residentId,
    required double amount,
    required DateTime paymentDate,
  }) async {
    await client.from('payments').insert({
      'resident_id': residentId,
      'amount_paid': amount,
      'payment_date': paymentDate.toIso8601String(),
      'month': paymentDate.month,
      'year': paymentDate.year,
    });
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final response = await client
        .from('depense')
        .select()
        .order('created_at', ascending: false);
    
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> addExpense({required String name, required double amount, required String description}) async {
    try {
      final response = await client
          .from('depense')
          .insert({
            'name': name,
            'amount': amount,
            'description': description,
          });

      debugPrint('Response Data: $response');
    } catch (e) {
      debugPrint('Error in addExpense: $e');
      rethrow;
    }
  }

  Future<void> deleteExpense(int id) async {
    try {
      await client
          .from('depense')
          .delete()
          .eq('id', id);
    } catch (e) {
      debugPrint('Error deleting expense: $e');
      rethrow;
    }
  }

  Future<List<Payment>> getPayments() async {
    try {
      final response = await client
          .from('payments')
          .select('*, residents(name)')
          .order('payment_date', ascending: false);

      return (response as List)
          .map((payment) => Payment.fromJson({
                ...payment,
                'resident_name': payment['residents']['name'],
              }))
          .toList();
    } catch (e) {
      throw Exception('Failed to load payments: $e');
    }
  }

  Future<Payment> addPaymentNew({
    required int residentId,
    required double amount,
    required String monthsCovered,
  }) async {
    try {
      final resident = await client
          .from('residents')
          .select('name')
          .eq('id', residentId)
          .single();

      final response = await client.from('payments').insert({
        'resident_id': residentId,
        'amount': amount,
        'months_covered': monthsCovered,
        'payment_date': DateTime.now().toIso8601String(),
      }).select('*').single();

      return Payment.fromJson({
        ...response,
        'resident_name': resident['name'],
      });
    } catch (e) {
      throw Exception('Failed to add payment: $e');
    }
  }
}

class Payment {
  final int id;
  final int residentId;
  final double amount;
  final String monthsCovered;
  final DateTime paymentDate;
  final String residentName;

  Payment({
    required this.id,
    required this.residentId,
    required this.amount,
    required this.monthsCovered,
    required this.paymentDate,
    required this.residentName,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'],
      residentId: json['resident_id'],
      amount: json['amount'],
      monthsCovered: json['months_covered'],
      paymentDate: DateTime.parse(json['payment_date']),
      residentName: json['resident_name'],
    );
  }
}
