import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:emailjs/emailjs.dart' as emailjs;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  late String _name;
  late String _userRole;
  late String _email;
  late String homeRoute;
  final String credentials = dotenv.env['GOOGLE_CREDENTIALS']!;
  final String spreadsheetId = dotenv.env['SPREADSHEET_ID']!;

  String _generateOtp() {
    final random = Random();
    String otp =
        (random.nextInt(900000) + 100000).toString(); // generate 6-digit OTP
    return otp;
  }

  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(Icons.error, size: 50, color: Colors.red),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showOtpDialog() {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Hello $_name!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Please check your email for your login code.'),
              TextField(
                controller: _otpController,
                decoration: const InputDecoration(labelText: 'Enter OTP'),
                keyboardType: TextInputType.number,
                maxLength: 6,
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: _validateOtp,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: const Text('Login', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Close', style: TextStyle(color: Colors.black)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _sendOtp() async {
    final entEmail = _emailController.text.trim();
    if (entEmail.isEmpty) {
      _showErrorDialog('Please enter an email address.');
      return;
    }

    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle('Set up login');
    if (sheet == null) return;

    final emails = await sheet.values.column(1, fromRow: 2); // Get the email column
    if (emails.contains(entEmail)) {
      final rowIndex = emails.indexOf(entEmail) + 2; // Adjust for 0-index and header row

      _name = await sheet.values.value(column: 3, row: rowIndex);
      _userRole = await sheet.values.value(column: 5, row: rowIndex);
      _email = entEmail;

      final otp = _generateOtp();
      await _storeOtp(_email, otp);
      await _sendEmail(_email, otp);
      _showOtpDialog();
    } else {
      _showErrorDialog('The email address $entEmail is not registered.');
    }
  }

  Future<void> _storeOtp(String email, String otp) async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle('Set up login');
    if (sheet == null) return;
    final emails = await sheet.values.column(1, fromRow: 2); // Fetch emails from column 1
    final rowIndex = emails.indexOf(email) + 2; // Adjust for 0-index and header row
    await sheet.values.insertValue(otp, row: rowIndex, column: 2); // Store OTP in column 2
  }

  Future<void> _sendEmail(String entEmail, String otp) async {
    const serviceId = 'service_6crv3yv';
    const templateId = 'template_hj5sqp9';
    const publicKey = 'sIxqVpwa4pGP1OVG8';
    const privateKey = 'XC0s-mApSoyIMo6_ahVlZ';

    final templateParams = {
      'user_email': entEmail,
      'user_otp': otp,
    };

    try {
      await emailjs.send(
        serviceId,
        templateId,
        templateParams,
        const emailjs.Options(publicKey: publicKey, privateKey: privateKey),
      );
    } catch (e) {
      _showErrorDialog('Failed to send email. Please try again.');
    }
  }

  Future<void> _validateOtp() async {
    final entOtp = _otpController.text.trim();
    if (entOtp.isEmpty) {
      _showErrorDialog('Please enter OTP.');
      return;
    }

    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle('Set up login');
    if (sheet == null) return;

    final otps = await sheet.values.column(2, fromRow: 2); // Fetch OTP column
    if (otps.contains(entOtp)) {
      final rowIndex = otps.indexOf(entOtp) + 2; // Adjust for 0-index and header row
      await _deleteOtp(rowIndex);
    } else {
      _showErrorDialog('Invalid OTP.');
    }
  }

  Future<void> _deleteOtp(int rowIndex) async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle('Set up login');
    if (sheet == null) return;

    await sheet.values.insertValue('', row: rowIndex, column: 2); // Clear the OTP in column 2
    _showWelcomeDialog();
  }

  void _showWelcomeDialog() {
    if (!mounted) return;
    _loginHistory(_email);
    // Navigate to home screen
    if (_userRole == 'Super Admin') {
      Navigator.pushReplacementNamed(context, '/sAdminHome');
    }
    if (_userRole == 'Admin') {
      Navigator.pushReplacementNamed(context, '/adminHome');
    }
    if (_userRole == 'Committee Member') {
      Navigator.pushReplacementNamed(context, '/memberHome');
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Icon(
            Icons.check_circle_outline,
            size: 60,
            color: Colors.green,
          ),
          content: Text(
            'Welcome back $_userRole $_name!',
            style: const TextStyle(fontSize: 20),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(color: Colors.blue),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _loginHistory(String email) async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle('Login History');
    if (sheet == null) return;

    final DateTime now = DateTime.now();
    final String formattedDateTime = '${now.month}/${now.day}/${now.year} ${now.hour}:${now.minute}:${now.second}';

    final loginData = [formattedDateTime, email];
    await sheet.values.appendRow(loginData);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFD0E4CC),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Log In Form',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: 320,
                child: TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    fillColor: Colors.white,
                    filled: true,
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: 300,
                child: ElevatedButton(
                  onPressed: _sendOtp,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Colors.green,
                  ),
                  child: const Text('Send OTP'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}