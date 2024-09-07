import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'creds.dart';

class ErrorHandling {
  // This function displays an error dialog and logs the error
  static Future<void> showErrorDialog(BuildContext context, String message) async {
    // Show the error dialog
    if (context.mounted) {
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
    // Log the error in the Google Sheets
    await logError(message);
  }
  // This function logs the error message with date and time in Google Sheets
  static Future<void> logError(String message) async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final errorSheet = ss.worksheetByTitle('Error');

    final now = DateTime.now();
    final date = '${now.month}/${now.day}/${now.year}';
    final time = '${now.hour}:${now.minute}:${now.second}';

    // Append the error details
    await errorSheet?.values.appendRow([date, time, message]);
  }
}