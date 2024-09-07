import 'package:flutter_dotenv/flutter_dotenv.dart';

final String credentials = dotenv.env['GOOGLE_CREDENTIALS']!;
final String spreadsheetId = dotenv.env['SPREADSHEET_ID']!;