import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const LoanPredictorApp());
}

class LoanPredictorApp extends StatelessWidget {
  const LoanPredictorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loan Prediction',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const LoanFormPage(),
    );
  }
}

class LoanFormPage extends StatefulWidget {
  const LoanFormPage({super.key});

  @override
  State<LoanFormPage> createState() => _LoanFormPageState();
}

class _LoanFormPageState extends State<LoanFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {
    'no_of_dependents': '',
    'education': '',
    'self_employed': '',
    'income_annum': '',
    'loan_amount': '',
    'loan_term': '',
    'cibil_score': '',
    'residential_assets_value': '',
    'commercial_assets_value': '',
    'luxury_assets_value': '',
    'bank_asset_value': '',
  };

  String _result = '';

  Future<void> _submitData() async {
    final url = Uri.parse('http://127.0.0.1:5000/predict'); // update if deployed

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(_formData.map((k, v) => MapEntry(k, num.tryParse(v) ?? 0))),
      );

      if (response.statusCode == 200) {
        final resultData = jsonDecode(response.body);
        setState(() {
          _result = resultData['loan_status'];
        });
      } else {
        setState(() {
          _result = 'Server Error: ${response.statusCode}';
        });
      }
    } catch (e) {
      setState(() {
        _result = 'Error: $e';
      });
    }
  }

  Widget _buildTextField(String label, String key) {
    return TextFormField(
      decoration: InputDecoration(labelText: label),
      onChanged: (value) => _formData[key] = value,
      keyboardType: TextInputType.number,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Loan Prediction')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            _buildTextField('No. of Dependents', 'no_of_dependents'),
            _buildTextField('Education (0 = Graduate, 1 = Not Graduate)', 'education'),
            _buildTextField('Self Employed (0 = No, 1 = Yes)', 'self_employed'),
            _buildTextField('Income Annum', 'income_annum'),
            _buildTextField('Loan Amount', 'loan_amount'),
            _buildTextField('Loan Term (months)', 'loan_term'),
            _buildTextField('CIBIL Score', 'cibil_score'),
            _buildTextField('Residential Assets Value', 'residential_assets_value'),
            _buildTextField('Commercial Assets Value', 'commercial_assets_value'),
            _buildTextField('Luxury Assets Value', 'luxury_assets_value'),
            _buildTextField('Bank Asset Value', 'bank_asset_value'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _submitData,
              child: const Text('Predict Loan Approval'),
            ),
            const SizedBox(height: 20),
            if (_result.isNotEmpty)
              Text(
                'Prediction Result: $_result',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
