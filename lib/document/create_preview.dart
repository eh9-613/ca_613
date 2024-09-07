// ignore_for_file: avoid_print
import 'package:googleapis/docs/v1.dart' as docs;
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'package:universal_html/html.dart' as html;
import 'package:gsheets/gsheets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class CreatePreview {
  final List<String> scopes = [
    'https://www.googleapis.com/auth/drive',
    'https://www.googleapis.com/auth/documents',
  ];

  final String credentials = dotenv.env['GOOGLE_CREDENTIALS']!;
  final String spreadsheetId = dotenv.env['SPREADSHEET_ID']!;

  Future<AutoRefreshingAuthClient> _getClient() async {
    final credential = ServiceAccountCredentials.fromJson(credentials,
        impersonatedUser: "eh9@kawalanseripadang.com");
    return await clientViaServiceAccount(credential, scopes);
  }

  Future<Map<String, String>> fetchSheetData() async {
    try {
      final gsheets = GSheets(credentials);
      final ss = await gsheets.spreadsheet(spreadsheetId);
      final sheet = ss.worksheetByTitle('Header Details');
      if (sheet == null) return {};

      final Map<String, String> data = {
        'address': await sheet.values.value(column: 2, row: 2),
        'emails': await sheet.values.value(column: 3, row: 2),
        'refNo': await sheet.values.value(column: 4, row: 2),
        'registrationNumber': await sheet.values.value(column: 5, row: 2),
        'resolutionTitle': await sheet.values.value(column: 6, row: 2),
        'telephoneNumbers': await sheet.values.value(column: 7, row: 2),
      };

      return data;
    } catch (e) {
      print('Error fetching data from Google Sheets: $e');
      return {};
    }
  }

  // Helper function to get current datetime in the required format
  String _getFormattedDateTime() {
    final now = DateTime.now();
    final formatter = DateFormat('yyyyMMddHHmm');
    return formatter.format(now);
  }

  Future<void> createPreview({
    required String issueDate,
    required String title,
    required String background,
    required String resolutionContent,
    required String additionalContent,
  }) async {
    try {
      final sheetData = await fetchSheetData();
      final client = await _getClient();
      final driveApi = drive.DriveApi(client);
      final docsApi = docs.DocsApi(client);

      const folderId = '10UQftQkgn3-DgkWkNCqZU7Aq9N5N-e-M';
      const templateId = '1RSFNCoGxqk_zvnJRKeczraPeJgMiDBiaquTLcnDVakI';

      final copiedFile = drive.File()
        ..name = title
        ..parents = [folderId];

      final copiedFileResponse =
          await driveApi.files.copy(copiedFile, templateId);
      final documentId = copiedFileResponse.id;

      if (documentId == null) {
        throw Exception('Failed to copy the document: documentId is null');
      }

      print('Document copied successfully with ID: $documentId');

      final doc = await docsApi.documents.get(documentId);
      final bodyContent = doc.body?.content;

      int endIndex = 1;
      if (bodyContent != null && bodyContent.isNotEmpty) {
        for (var element in bodyContent) {
          if (element.endIndex != null) {
            endIndex = element.endIndex!;
          }
        }
      }

      if (endIndex <= 1) {
        endIndex = 1;
      }

      // Get formatted refNo with date-time
      final refNo = sheetData['refNo'] ?? '';
      final dateTimeString = _getFormattedDateTime();
      final refNoWithDateTime = '$refNo/RESO/$dateTimeString';

      // Prepare requests to replace placeholders
      final requests = <docs.Request>[
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{date}',
              matchCase: false,
            ),
            replaceText: issueDate,
          ),
        ),
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{title}',
              matchCase: false,
            ),
            replaceText: title,
          ),
        ),
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{background}',
              matchCase: false,
            ),
            replaceText: background,
          ),
        ),
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{contentResolution}',
              matchCase: false,
            ),
            replaceText: resolutionContent,
          ),
        ),
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{documentSubject}',
              matchCase: false,
            ),
            replaceText: sheetData['resolutionTitle'] ?? '',
          ),
        ),
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{RegistrationNo}',
              matchCase: false,
            ),
            replaceText: sheetData['registrationNumber'] ?? '',
          ),
        ),
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{officeAddress}',
              matchCase: false,
            ),
            replaceText: sheetData['address'] ?? '',
          ),
        ),
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{numbers}',
              matchCase: false,
            ),
            replaceText: sheetData['telephoneNumbers'] ?? '',
          ),
        ),
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{emails}',
              matchCase: false,
            ),
            replaceText: sheetData['emails'] ?? '',
          ),
        ),
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{additional}',
              matchCase: false,
            ),
            replaceText: "$additionalContent\n",
          ),
        ),
        docs.Request(
          replaceAllText: docs.ReplaceAllTextRequest(
            containsText: docs.SubstringMatchCriteria(
              text: '{refNo}',
              matchCase: false,
            ),
            replaceText: refNoWithDateTime,
          ),
        ),
      ];

      final batchUpdateRequest =
          docs.BatchUpdateDocumentRequest(requests: requests);
      await docsApi.documents.batchUpdate(batchUpdateRequest, documentId);

      final committeedata = await fetchCommitteeData();
      print(committeedata);
      await updateTable(documentId, committeedata);
      const imagefolderId = '1NxKP7TNA55zSCvJ2cGyzHHXTK9XPEuVu';
      // Find the last image in the folder and get its ID
      final imageId =
          await findLastImageInFolder(imagefolderId); // Update to await result
      if (imageId != null) {
        // Insert image at the bottom of the document
        await insertImageAtBottom(documentId, imageId);
      } else {
        print('No image found to insert.');
      }
      await convertDocToPdfAndUpload(
          documentId: documentId, folderId: folderId, pdfName: title);

      final latestPdf = await getLatestPdfFile(driveApi, folderId);

      if (latestPdf != null) {
        // Safely access properties only if latestPdf is not null
        print('Latest PDF File Name: ${latestPdf.name}');
        print('Latest PDF File ID: ${latestPdf.id}');
        print('Latest PDF File Modified Time: ${latestPdf.modifiedTime}');

        // Check if the ID is not null before opening
        final pdfId = latestPdf.id; // This might be null
        if (pdfId != null) {
          openPdfInNewTab(pdfId); // Safely open the PDF if ID is not null
        } else {
          print('Error: PDF ID is null.');
        }
      } else {
        print('No PDF file found.');
      }

      print('Document updated successfully');
    } catch (e) {
      print('Error processing document: $e');
    }
  }

  Future<List<Map<String, String>>> fetchCommitteeData() async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final sheet = ss.worksheetByTitle('Committee Members');

    if (sheet == null) return [];

    // Fetch all rows from the sheet
    final rows =
        await sheet.values.allRows(fromRow: 2); // fromRow: 2 to skip headers

    // Map to store committee data
    final List<Map<String, String>> committeeData = [];

    for (var row in rows) {
      if (row.isNotEmpty) {
        final name = row[0]; // Assuming name is in column 1
        if (name.isNotEmpty) {
          committeeData.add({'Name': name});
        }
      }
    }

    return committeeData;
  }

  Future<void> updateTable(
      String newDocId, List<Map<String, String>> committeeData) async {
    final authClient = await _getClient();
    final docsApi = docs.DocsApi(authClient);

    // Retrieve the document content
    var document = await docsApi.documents.get(newDocId);
    var content = document.body!.content!;

    // Find the table within the document
    docs.Table? targetTable;
    int tableIndex = -1; // Initialize with -1 to indicate table not found
    for (var i = 0; i < content.length; i++) {
      if (content[i].table != null) {
        targetTable = content[i].table;
        tableIndex = i;
        break;
      }
    }

    if (targetTable != null) {
      final tableStartIndex = content[tableIndex].startIndex!;

      for (var row = 0; row < committeeData.length; row++) {
        final requests = <Map<String, dynamic>>[];

        // Insert a new row below the last row
        requests.add({
          'insertTableRow': {
            'tableCellLocation': {
              'tableStartLocation': {'index': tableStartIndex},
              'rowIndex': targetTable!.tableRows!.length - 1,
              'columnIndex': 0,
            },
            'insertBelow': true,
          },
        });

        final rowInsertBatchUpdateRequest = docs.BatchUpdateDocumentRequest(
          requests: requests.map((req) => docs.Request.fromJson(req)).toList(),
        );
        await docsApi.documents
            .batchUpdate(rowInsertBatchUpdateRequest, newDocId);

        // Recalculate document content and indices after inserting the row
        document = await docsApi.documents.get(newDocId);
        content = document.body!.content!;
        targetTable = content[tableIndex].table!;

        final newRowIndex = targetTable.tableRows!.length - 1;
        final committeeName = committeeData[row]['Name'];

        if (committeeName != null && committeeName.isNotEmpty) {
          final newRowFirstCell =
              targetTable.tableRows![newRowIndex].tableCells!.first;
          final newRowFirstCellStartIndex = newRowFirstCell.startIndex!;

          final textInsertRequests = <Map<String, dynamic>>[];
          final updateTextStyleRequests = <Map<String, dynamic>>[];

          textInsertRequests.add({
            'insertText': {
              'location': {'index': newRowFirstCellStartIndex + 1},
              'text': committeeName,
            },
          });

          updateTextStyleRequests.add({
            'updateTextStyle': {
              'range': {
                'startIndex': newRowFirstCellStartIndex + 1,
                'endIndex':
                    newRowFirstCellStartIndex + 1 + committeeName.length,
              },
              'textStyle': {
                'bold': false,
                'fontSize': {'magnitude': 16.0, 'unit': 'PT'},
              },
              'fields': '*',
            },
          });

          // Add the second cell text
          final newRowSecondCell =
              targetTable.tableRows![newRowIndex].tableCells![1];
          final newRowSecondCellStartIndex =
              newRowSecondCell.startIndex! + committeeName.length + 1;
          final newRowSecondCellValue = '[[s|${row + 1}]]';

          textInsertRequests.add({
            'insertText': {
              'location': {'index': newRowSecondCellStartIndex},
              'text': newRowSecondCellValue,
            },
          });

          updateTextStyleRequests.add({
            'updateTextStyle': {
              'range': {
                'startIndex': newRowSecondCellStartIndex,
                'endIndex':
                    newRowSecondCellStartIndex + newRowSecondCellValue.length,
              },
              'textStyle': {
                'foregroundColor': {
                  'color': {
                    'rgbColor': {'red': 1.0, 'green': 1.0, 'blue': 1.0}
                  }
                },
                'fontSize': {'magnitude': 16.0, 'unit': 'PT'},
              },
              'fields': '*',
            },
          });

          final textInsertBatchUpdateRequest = docs.BatchUpdateDocumentRequest(
            requests: textInsertRequests
                .map((req) => docs.Request.fromJson(req))
                .toList(),
          );

          final updateTextStyleBatchUpdateRequest =
              docs.BatchUpdateDocumentRequest(
            requests: updateTextStyleRequests
                .map((req) => docs.Request.fromJson(req))
                .toList(),
          );

          try {
            await docsApi.documents
                .batchUpdate(textInsertBatchUpdateRequest, newDocId);
            await docsApi.documents
                .batchUpdate(updateTextStyleBatchUpdateRequest, newDocId);
            print('Table updated successfully with committee data.');
          } catch (e) {
            print('Failed to update table with committee data: $e');
          }
        } else {
          print('Error: Committee Name is null or empty for Row $row');
        }
      }
    } else {
      print('Target table not found.');
    }

    authClient.close();
  }

  Future<String?> findLastImageInFolder(String folderId) async {
    try {
      final client = await _getClient();
      final driveApi = drive.DriveApi(client);

      final fileListResponse = await driveApi.files.list(
        q: "'$folderId' in parents and mimeType contains 'image/'",
        orderBy: 'createdTime desc',
        pageSize: 1,
      );

      final files = fileListResponse.files;
      if (files != null && files.isNotEmpty) {
        final latestImage = files.first;
        print('Last image ID: ${latestImage.id}');
        return latestImage.id; // Return the image ID
      } else {
        print('No images found in the folder.');
        return null; // Return null if no images are found
      }
    } catch (e) {
      print('Error finding the last image: $e');
      return null; // Return null in case of error
    }
  }

  Future<int> calculateLastIndex(String documentId) async {
    try {
      final client =
          await _getClient(); // Your method to get an authenticated client
      final docsApi = docs.DocsApi(client);

      // Fetch the document content
      final document = await docsApi.documents.get(documentId);
      final content = document.body?.content;

      if (content == null || content.isEmpty) {
        print('Document is empty.');
        return 1; // Start index for a new document
      }

      // Find the end index of the last element
      int lastIndex = 1; // Default start index if no content is found
      for (var element in content) {
        if (element.endIndex != null) {
          lastIndex = element.endIndex! - 1;
        }
      }

      return lastIndex;
    } catch (e) {
      print('Error calculating the last index: $e');
      return 1; // Default start index in case of error
    }
  }

  Future<void> insertImageAtBottom(String documentId, String imageId) async {
    try {
      final client =
          await _getClient(); // Your method to get an authenticated client
      final docsApi = docs.DocsApi(client);

      // Calculate the last index
      final lastIndex = await calculateLastIndex(documentId);

      // Create the request to insert the image
      final requests = <docs.Request>[
        docs.Request(
          insertInlineImage: docs.InsertInlineImageRequest(
              uri:
                  'https://drive.google.com/uc?id=$imageId', // Google Drive image URL
              location: docs.Location(index: lastIndex)),
        ),
      ];

      final batchUpdateRequest =
          docs.BatchUpdateDocumentRequest(requests: requests);
      await docsApi.documents.batchUpdate(batchUpdateRequest, documentId);

      print('Image inserted at the bottom of the document.');
    } catch (e) {
      print('Error inserting image: $e');
    }
  }

  Future<void> convertDocToPdfAndUpload({
    required String documentId,
    required String folderId,
    required String pdfName, // New parameter for the PDF file name
  }) async {
    try {
      final client =
          await _getClient(); // Ensure you have an authenticated client
      final driveApi = drive.DriveApi(client);

      // Export the document as PDF
      final exportUrl =
          'https://www.googleapis.com/drive/v3/files/$documentId/export?mimeType=application/pdf';
      final response = await client.get(Uri.parse(exportUrl));

      print('Export URL: $exportUrl');

      if (response.statusCode == 200) {
        final pdfBytes = response.bodyBytes;

        // Create metadata for the PDF file
        final pdfFile = drive.File()
          ..name = pdfName // Use the provided PDF name
          ..parents = [folderId];

        // Create a media object with the PDF bytes
        final media =
            drive.Media(Stream.fromIterable([pdfBytes]), pdfBytes.length);

        // Upload the PDF file to Google Drive
        final uploadedFile =
            await driveApi.files.create(pdfFile, uploadMedia: media);
        print('PDF uploaded successfully with ID: ${uploadedFile.id}');
      } else {
        print(
            'Failed to export document as PDF: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error converting and uploading document: $e');
    }
  }

  Future<drive.File?> getLatestPdfFile(
      drive.DriveApi driveApi, String folderId) async {
    try {
      // Query to list files in the specified folder with mimeType 'application/pdf'
      final fileList = await driveApi.files.list(
        q: "'$folderId' in parents and mimeType='application/pdf'",
        orderBy: 'modifiedTime desc',
        pageSize: 1,
      );

      // Check if any files are returned
      if (fileList.files != null && fileList.files!.isNotEmpty) {
        return fileList.files![0]; // Latest PDF file
      } else {
        print('No PDF files found in the folder.');
        return null;
      }
    } catch (error) {
      print('An error occurred while fetching the latest PDF file: $error');
      return null;
    }
  }

  void openPdfInNewTab(String documentId) {
    // Construct the URL to the PDF file
    final pdfUrl =
        'https://drive.google.com/file/d/$documentId/view?usp=drive_link';

    // Open the URL in a new tab
    html.window.open(pdfUrl, '_blank');
  }
}