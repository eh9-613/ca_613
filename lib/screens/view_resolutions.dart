// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../widgets/custom_app_bar.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:universal_html/html.dart' as html;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:gsheets/gsheets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

final List<String> scopes = [
  'https://www.googleapis.com/auth/drive',
  'https://www.googleapis.com/auth/documents',
];

Future<AutoRefreshingAuthClient> _getClient() async {
  final credentialsJson = dotenv.env['GOOGLE_CREDENTIALS'];
  if (credentialsJson == null) {
    throw Exception('GOOGLE_CREDENTIALS environment variable is not set.');
  }

  final Map<String, dynamic> credentialsMap = jsonDecode(credentialsJson);
  final credential = ServiceAccountCredentials.fromJson(credentialsMap);

  return await clientViaServiceAccount(credential, scopes);
}

void openPdfInNewTab(String documentId) {
  final pdfUrl =
      'https://drive.google.com/file/d/$documentId/view?usp=drive_link';
  html.window.open(pdfUrl, '_blank');
}

Future<void> convertDocToPdfAndUpload({
  required String documentId,
  required String folderId,
  required String title,
}) async {
  try {
    final client = await _getClient();
    final driveApi = drive.DriveApi(client);

    final exportUrl =
        'https://www.googleapis.com/drive/v3/files/$documentId/export?mimeType=application/pdf';
    final response = await client.get(Uri.parse(exportUrl));

    if (response.statusCode == 200) {
      final pdfBytes = response.bodyBytes;

      final pdfFile = drive.File()
        ..name = title
        ..parents = [folderId];

      final media =
          drive.Media(Stream.fromIterable([pdfBytes]), pdfBytes.length);

      final uploadedFile =
          await driveApi.files.create(pdfFile, uploadMedia: media);
      openPdfInNewTab(uploadedFile.id!);
    } else {
      print(
          'Failed to export document as PDF: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error converting and uploading document: $e');
  }
}

class ViewResolutionsPage extends StatefulWidget {
  const ViewResolutionsPage({super.key});

  @override
  ViewResolutionsPageState createState() => ViewResolutionsPageState();
}

class ViewResolutionsPageState extends State<ViewResolutionsPage> {
  GSheets? gsheets;
  final http.Client client = http.Client();
  drive.DriveApi? driveApi;
  final String spreadsheetId = dotenv.env['SPREADSHEET_ID']!;
  final String credentials = dotenv.env['GOOGLE_CREDENTIALS']!;

  @override
  void initState() {
    super.initState();
    _initializeClients();
  }

  Future<void> _initializeClients() async {
    final authClient = await _getClient();
    setState(() {
      gsheets = GSheets(authClient);
      driveApi = drive.DriveApi(authClient);
    });
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }

  int _sortColumnIndex =
      0; // Index of the column to sort by (Reference Number column)
  bool _sortAscending = true;

  Future<List<Map<String, dynamic>>> fetchPdfData() async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final pdfDataSheet = ss.worksheetByTitle('List of Created PDF');
    if (pdfDataSheet == null) {
      throw 'Worksheet not found';
    }

    final allRows = await pdfDataSheet.values.allRows(fromRow: 2);

    // Assuming the headers are: Document ID, Reference Number, Name, Link, Signed Link, Status
    return allRows.map<Map<String, dynamic>>((row) {
      return {
        'Document ID': row[0],
        'Reference Number': row[1],
        'Name': row[2],
        'Link': row[3],
        'Signed Link': row[4],
        'Status': row[5], // Default to 'Draft' if status is missing
      };
    }).toList();
  }

  void _showFinalizedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Document Finalized'),
          content: const Text(
            'This document is now finalized and cannot be edited. A SignRequest will be sent to the corresponding emails of the management members soon.',
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void _launchURL(String? url, String label) async {
    if (url != null && await canLaunchUrlString(url)) {
      await launchUrlString(url);
    } else {
      throw 'Could not launch $label';
    }
  }

  Future<void> _handlePreview(
      String documentId, String folderId, String title) async {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent dismissing dialog on outside tap
      builder: (BuildContext context) {
        return const AlertDialog(
          title: Text('Converting and Uploading'),
          content: SizedBox(
            height: 100,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Please wait...'),
                ],
              ),
            ),
          ),
        );
      },
    );

    // Perform document conversion and upload
    convertDocToPdfAndUpload(
        documentId: documentId,
        folderId: '1ktYMiKsPPBGCNYifUpWhOMDF81uPkmoI',
        title: title);

    // Close the loading dialog
    Navigator.of(context).pop();
  }

  Future<void> _updateStatus(
      String documentId, String newStatus, String title) async {
    try {
      final gsheets = GSheets(credentials);
      final ss = await gsheets.spreadsheet(spreadsheetId);
      final sheet = ss.worksheetByTitle('List of Created PDF');
      if (sheet == null) return;

      final List<String> documentIds = await sheet.values.column(1);
      int rowIndex =
          documentIds.indexOf(documentId) + 1; // +1 because rows are 1-indexed

      if (rowIndex > 0) {
        await sheet.values.insertValue(newStatus, column: 6, row: rowIndex);

        // Check if the new status is 'Final'
        if (newStatus == 'Final') {
          // Show the popup dialog
          _showFinalizedDialog();
          sendWebhookToMake(documentId, title);
        }
      } else {
        print('Document ID not found');
      }
    } catch (e) {
      print('Error updating status: $e');
    }
  }

  void openPdfInNewTab(String documentId) {
    final pdfUrl =
        'https://drive.google.com/file/d/$documentId/view?usp=drive_link';
    html.window.open(pdfUrl, '_blank');
  }

  Future<List<String>> fetchCommitteeEmails() async {
    try {
      final gsheets = GSheets(credentials);
      final ss = await gsheets.spreadsheet(spreadsheetId);
      final sheet = ss.worksheetByTitle('Committee Members');
      if (sheet == null) return [];

      // Fetch all emails from column 2 (B)
      final emails = await sheet.values.column(2, fromRow: 2);

      return emails;
    } catch (e) {
      print('Error fetching committee emails: $e');
      return [];
    }
  }

  Future<void> sendWebhookToMake(String newDocId, String newTitle) async {
    const String makeWebhookURL =
        'https://hook.eu2.make.com/iji6vqn3fsb7nmlm27airvs6c68cz5a9';

    List<String> committeeEmails = await fetchCommitteeEmails();
    print('emails: $committeeEmails');

    final Map<String, dynamic> payload = {
      "docUrl": newDocId,
      "emails": committeeEmails,
      "title": newTitle,
    };

    String payloadData = jsonEncode(payload);
    print('payload: $payloadData');

    try {
      final http.Response response = await http.post(
        Uri.parse(makeWebhookURL),
        headers: {
          'Content-Type': 'application/json', // Set the content type to JSON
        },
        body: payloadData,
      );

      if (response.statusCode == 200) {
        print('Webhook sent successfully to Make');
      } else {
        print('Failed to send webhook to Make: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (e) {
      print('Error sending webhook to Make: $e');
    }
  }

  Future<String?> getSignedDocumentLink(String title) async {
    try {
      final gsheets = GSheets(credentials);
      final ss = await gsheets.spreadsheet(spreadsheetId);
      final sheet = ss.worksheetByTitle('Signed Document Link');
      if (sheet == null) return null;

      final List<String?> titles = await sheet.values.column(3);
      final int rowIndex = titles.indexOf(title);

      if (rowIndex != -1) {
        // Assuming the signed link is in the second column (E)
        final signedLink =
            await sheet.values.value(column: 5, row: rowIndex + 1);
        return signedLink;
      } else {
        return null; // Document title not found
      }
    } catch (e) {
      print('Error fetching signed document link: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(), // Use your custom app bar here
      backgroundColor: const Color(0xFFD0E4CC), // Set background color
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchPdfData(),
        builder: (BuildContext context,
            AsyncSnapshot<List<Map<String, dynamic>>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No data available'));
          } else {
            List<Map<String, dynamic>> pdfData = snapshot.data!;

            // Sorting the data based on Reference Number column
            pdfData.sort((a, b) => _sortAscending
                ? (a['Reference Number'] ?? '')
                    .compareTo(b['Reference Number'] ?? '')
                : (b['Reference Number'] ?? '')
                    .compareTo(a['Reference Number'] ?? ''));

            return Center(
              // Center the table
              child: Padding(
                padding:
                    const EdgeInsets.all(16.0), // Add padding around the table
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white, // Set background color of the table
                      border: Border.all(
                          color: Colors.black.withOpacity(0.3), width: 1),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: DataTable(
                      columnSpacing: 20.0,
                      sortColumnIndex: _sortColumnIndex,
                      sortAscending: _sortAscending,
                      columns: [
                        DataColumn(
                          label: const Text('Reference Number'),
                          onSort: (columnIndex, ascending) {
                            setState(() {
                              _sortColumnIndex = columnIndex;
                              _sortAscending = ascending;
                            });
                          },
                        ),
                        const DataColumn(label: Text('Name')),
                        const DataColumn(label: Text('Unsigned Document Link')),
                        const DataColumn(label: Text('Signed Document Link')),
                        const DataColumn(label: Text('Status')),
                        const DataColumn(label: Text('Edit')),
                        const DataColumn(label: Text('Preview')),
                      ],
                      rows: pdfData.map((data) {
                        String documentId = data['Document ID'] ?? '';
                        String status = data['Status'] ?? 'Draft';
                        String unsignedLink = data['Link'] ?? '';
                        String signedLink = data['Signed Link'] ?? '';

                        return DataRow(
                          cells: [
                            DataCell(Text(data['Reference Number'] ?? '')),
                            DataCell(Text(data['Name'] ?? '')),
                            DataCell(
                              unsignedLink.isNotEmpty
                                  ? InkWell(
                                      onTap: () => _launchURL(unsignedLink,
                                          'Unsigned Document Link'),
                                      child: const Text(
                                        'Click to view',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                  : const Text('No link'),
                            ),
                            DataCell(
                              signedLink.isNotEmpty
                                  ? InkWell(
                                      onTap: () => _launchURL(
                                          signedLink, 'Signed Document Link'),
                                      child: const Text(
                                        'Click to view',
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    )
                                  : const Text('No link'),
                            ),
                            DataCell(
                              DropdownButton<String>(
                                value: status,
                                items: ['Draft', 'Final'].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  if (newValue != null && status != 'Final') {
                                    setState(() {
                                      _updateStatus(documentId, newValue,
                                          data['Name'] ?? '');
                                    });
                                  }
                                },
                                disabledHint: Text(status),
                                underline: const SizedBox(),
                              ),
                            ),
                            DataCell(
                              status != 'Final'
                                  ? IconButton(
                                      icon: const Icon(Icons.edit_document),
                                      onPressed: () {
                                        _launchURL(
                                            unsignedLink, 'Edit Document');

                                        // Show the Snackbar
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "If your changes don't show, consider refreshing the page"),
                                            duration: Duration(seconds: 3),
                                          ),
                                        );
                                      },
                                    )
                                  : const SizedBox(
                                      child: Icon(
                                        Icons.edit_off,
                                        color: Colors
                                            .grey, // Grey color to indicate it's disabled
                                      ),
                                    ),
                            ),
                            DataCell(
                              IconButton(
                                icon: const Icon(Icons.visibility),
                                onPressed: () {
                                  String folderId = data['FolderId'] ?? '';
                                  String title = data['Title'] ?? '';
                                  _handlePreview(documentId, folderId, title);
                                },
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}