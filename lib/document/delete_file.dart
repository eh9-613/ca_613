// ignore_for_file: avoid_print
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DeleteFiles {
  final List<String> scopes = [
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/documents',
  ];

  final String credentials = dotenv.env['GOOGLE_CREDENTIALS']!;
  final String spreadsheetId = dotenv.env['SPREADSHEET_ID']!;

  Future<AutoRefreshingAuthClient> getClient() async {
    final credential = ServiceAccountCredentials.fromJson(credentials,
        impersonatedUser: "eh9@kawalanseripadang.com");
    return await clientViaServiceAccount(credential, scopes);
  }

  Future<List<drive.File>> getLatestFiles(
      drive.DriveApi driveApi, String folderId, int count) async {
    try {
      // Query to list files in the specified folder
      final fileList = await driveApi.files.list(
        q: "'$folderId' in parents",
        orderBy: 'modifiedTime desc',
        pageSize: count,
      );

      // Check if any files are returned
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files!;
      } else {
        print('No files found in the folder.');
        return [];
      }
    } catch (error) {
      print('An error occurred while fetching the latest files: $error');
      return [];
    }
  }

  Future<void> deleteFiles(
      drive.DriveApi driveApi, String folderId, int count) async {
    try {
      final files = await getLatestFiles(driveApi, folderId, count);

      if (files.isNotEmpty) {
        for (final file in files) {
          await driveApi.files.delete(file.id!);
        }
      } else {
        print('No files to delete.');
      }
    } catch (error) {
      print('An error occurred while deleting files: $error');
    }
  }
}