// ignore_for_file: avoid_print, use_build_context_synchronously
import '../document/create_preview.dart';
import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import 'package:universal_html/html.dart' as html;
import 'dart:typed_data';
import '../document/create_letter.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import '../document/delete_file.dart';
import '../widgets/custom_app_bar.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:convert'; // Import for JSON decoding

class SubmitFormPage extends StatefulWidget {
  const SubmitFormPage({super.key});

  @override
  SubmitFormPageState createState() => SubmitFormPageState();
}

class SubmitFormPageState extends State<SubmitFormPage> {
  final TextEditingController issueDateController = TextEditingController();
  final TextEditingController titleController = TextEditingController();
  final TextEditingController backgroundController = TextEditingController();
  final TextEditingController resolutionContentController =
      TextEditingController();
  final TextEditingController additionalContentController =
      TextEditingController();
  Future<List<String>>? _committeeNames;
  CreateLetter createLetter = CreateLetter();
  CreatePreview createPreview = CreatePreview();
  final String spreadsheetId = dotenv.env['SPREADSHEET_ID']!;
  late final GSheets gsheets; // Declare `gsheets` as a class property
  bool _showAdditionalField = false;
  html.File? _imageFile; // Store image file
  String? _fileName;
  final _formKey = GlobalKey<FormState>(); // Store committee member names

  http.Client client = http.Client();
  drive.DriveApi? driveApi;
  final List<String> scopes = [drive.DriveApi.driveFileScope];

  @override
  void initState() {
    super.initState();
    _committeeNames =
        fetchCommitteeNames();
        gsheets = GSheets(dotenv.env['GOOGLE_CREDENTIALS']!); // Fetch committee members only once when the page initializes
  }

  @override
  void dispose() {
    client.close();
    super.dispose();
  }

  Future<AutoRefreshingAuthClient> _getAuthClient() async {
    final credentialsJson = dotenv.env['GOOGLE_CREDENTIALS'];
    if (credentialsJson == null) {
      throw Exception('GOOGLE_CREDENTIALS environment variable is not set.');
    }

    final Map<String, dynamic> credentialsMap = jsonDecode(credentialsJson);

    final credentials = ServiceAccountCredentials.fromJson(credentialsMap);

    final authClient = await clientViaServiceAccount(credentials, scopes);
    return authClient;
  }

  Future<void> uploadFile(html.File file) async {
    driveApi ??= await _getDriveApi();

    // Get file size
    final fileSize = file.size;

    // Read file as a stream
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    reader.onLoadEnd.listen((_) async {
      final fileBytes = reader.result as Uint8List;

      // Create a Media object with the file content
      final media = drive.Media(Stream.fromIterable([fileBytes]), fileSize);

      // Create a file metadata object
      final driveFile = drive.File();
      driveFile.name = file.name;
      driveFile.parents = [
        '1LxRcIsinUbHVdB0ybmvhgo82LOtaepTX'
      ]; // Specify the folder ID

      try {
        final response =
            await driveApi!.files.create(driveFile, uploadMedia: media);
        print('File uploaded successfully: ${response.id}');
        print('File name: ${file.name}');
        // Handle success if needed
      } catch (error) {
        print('An error occurred: $error');
        // Handle error as needed
      }
    });
  }

  Future<void> submituploadFile(html.File file) async {
    driveApi ??= await _getDriveApi();

    // Get file size
    final fileSize = file.size;

    // Read file as a stream
    final reader = html.FileReader();
    reader.readAsArrayBuffer(file);

    reader.onLoadEnd.listen((_) async {
      final fileBytes = reader.result as Uint8List;

      // Create a Media object with the file content
      final media = drive.Media(Stream.fromIterable([fileBytes]), fileSize);

      // Create a file metadata object
      final driveFile = drive.File();
      driveFile.name = file.name;
      driveFile.parents = [
        '1NxKP7TNA55zSCvJ2cGyzHHXTK9XPEuVu'
      ]; // Specify the folder ID

      try {
        final response =
            await driveApi!.files.create(driveFile, uploadMedia: media);
        print('File uploaded successfully: ${response.id}');
        print('File name: ${file.name}');
        // Handle success if needed
      } catch (error) {
        print('An error occurred: $error');
        // Handle error as needed
      }
    });
  }

  Future<drive.DriveApi> _getDriveApi() async {
    final authClient = await _getAuthClient();
    return drive.DriveApi(authClient);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      String formattedDate = '${picked.day}/${picked.month}/${picked.year}';
      issueDateController.text = formattedDate;
    }
  }

  Future<List<String>> fetchCommitteeNames() async {
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final memberData = ss.worksheetByTitle('Committee Members');
    if (memberData == null) {
      throw 'Worksheet not found';
    }

    final allCommitteeRows = await memberData.values.allRows(fromRow: 2);
    return allCommitteeRows.map<String>((row) {
      return row[0]; // Adjust the index based on your column setup
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: const CustomAppBar(),
        backgroundColor: const Color(0xFFD0E4CC),
        body: Center(
          child: Container(
            width: MediaQuery.of(context).size.width * 0.5,
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 5,
                  blurRadius: 7,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Resolution Letter Form',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: issueDateController,
                      readOnly: true,
                      onTap: () {
                        _selectDate(context);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select issue date';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Issue Date',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: titleController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter title';
                        }
                        return null;
                      },
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: backgroundController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter background';
                        }
                        return null;
                      },
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Background',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextFormField(
                      controller: resolutionContentController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter resolution content';
                        }
                        return null;
                      },
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText: 'Content of Resolution',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Committee for Signing:',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    FutureBuilder<List<String>>(
                      future: _committeeNames,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                              child: CircularProgressIndicator());
                        } else if (snapshot.hasError) {
                          return Center(
                              child: Text('Error: ${snapshot.error}'));
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                              child: Text('No names available.'));
                        } else {
                          final names = snapshot.data!;
                          return Column(
                            children: List.generate(
                              names.length,
                              (index) => ListTile(
                                leading: Text('${index + 1}.'),
                                title: Text(names[index]),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Additional Content',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _showAdditionalField = !_showAdditionalField;
                            });
                          },
                          icon: Icon(
                            _showAdditionalField
                                ? Icons.remove_circle
                                : Icons.add_circle,
                            color: _showAdditionalField
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Visibility(
                      visible: _showAdditionalField,
                      child: TextFormField(
                        controller: additionalContentController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter additional content';
                          }
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Additional Content',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Expanded(
                          flex: 2,
                          child: Text(
                            'Supporting Quotation for References Purposes',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  final input = html.FileUploadInputElement();
                                  input.accept =
                                      'image/*'; // Accept all types of images
                                  input.click();
                                  input.onChange.listen((e) {
                                    final files = input.files;
                                    if (files!.isEmpty) return;
                                    setState(() {
                                      _imageFile = files[0];
                                      _fileName = _imageFile!.name;
                                    });
                                  });
                                },
                                child: const Text('Upload'),
                              ),
                              const SizedBox(height: 8),
                              if (_fileName != null)
                                Text(
                                  'Selected file: $_fileName', // Display the file name
                                  style: const TextStyle(fontSize: 14),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.contains('/')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Title cannot contain "/" character. (because of Firebase rules)'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        if (_formKey.currentState!.validate() &&
                            _imageFile != null &&
                            additionalContentController.text.isNotEmpty) {
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                title: Text('Creating Letter'),
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 20),
                                    Text('Please wait...'),
                                  ],
                                ),
                              );
                            },
                          );

                          try {
                            // Upload image file to Google Drive
                            if (_imageFile != null) {
                              await submituploadFile(_imageFile!);
                            }
                            // Proceed with preview
                            await createLetter.createLetter(
                              issueDate: issueDateController.text,
                              title: titleController.text,
                              background: backgroundController.text,
                              resolutionContent:
                                  resolutionContentController.text,
                              additionalContent:
                                  additionalContentController.text,
                            );

                            // Clear all inputs
                            setState(() {
                              issueDateController.clear();
                              titleController.clear();
                              backgroundController.clear();
                              resolutionContentController.clear();
                              additionalContentController.clear();
                              _imageFile = null;
                              _showAdditionalField = false;
                            });
                          } catch (error) {
                            print('Error during creating letter: $error');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to create letter.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } finally {
                            // Close the loading dialog
                            Navigator.of(context).pop();

                            // Show the confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text(
                                      'Letter Created Successfully!'),
                                  content: const Text(
                                      'The SignRequest is now in draft. Once the status is changed to final it will be sent to the corresponding emails of the Management Members soon.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the confirmation dialog
                                      },
                                      child: const Text('OK'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please fill in all fields and upload the supporting quotation image.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Text('Submit'),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        if (titleController.text.contains('/')) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Title cannot contain "/" character. (because of firebase rules)'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          return;
                        }

                        if (_formKey.currentState!.validate() &&
                            _imageFile != null &&
                            additionalContentController.text.isNotEmpty) {
                          // Show loading dialog
                          showDialog(
                            context: context,
                            barrierDismissible: false,
                            builder: (BuildContext context) {
                              return const AlertDialog(
                                title: Text('Preparing Preview'),
                                content: Row(
                                  children: [
                                    CircularProgressIndicator(),
                                    SizedBox(width: 20),
                                    Text('Please wait...'),
                                  ],
                                ),
                              );
                            },
                          );

                          try {
                            // Upload image file to Google Drive
                            if (_imageFile != null) {
                              await uploadFile(_imageFile!);
                            }
                            // Proceed with preview
                            await createPreview.createPreview(
                              issueDate: issueDateController.text,
                              title: titleController.text,
                              background: backgroundController.text,
                              resolutionContent:
                                  resolutionContentController.text,
                              additionalContent:
                                  additionalContentController.text,
                            );
                          } catch (error) {
                            print('Error during preview: $error');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to preview data.'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          } finally {
                            // Close the loading dialog
                            Navigator.of(context).pop();

                            // Show the confirmation dialog
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Preview Complete'),
                                  content:
                                      const Text('Are you done previewing?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context)
                                            .pop(); // Close the confirmation dialog

                                        Future<void> delete() async {
                                          final deleteFiles = DeleteFiles();

                                          try {
                                            // Obtain the authenticated client
                                            final client =
                                                await deleteFiles.getClient();

                                            // Create a Drive API instance using the authenticated client
                                            final driveApi =
                                                drive.DriveApi(client);

                                            // Define folderId and the number of files to delete
                                            const folderId =
                                                '1qAuJ8TsBx3Al1WA5hMcEwdeKFeA_nNIc'; // Replace with your folder ID
                                            const count =
                                                2; // Number of latest files to delete

                                            // Call the deleteFiles method
                                            await deleteFiles.deleteFiles(
                                                driveApi, folderId, count);

                                            // Close the client when done
                                            client.close();

                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                    'Files deleted successfully'),
                                                backgroundColor: Colors.green,
                                              ),
                                            );
                                          } catch (e) {
                                            print('An error occurred: $e');
                                          }
                                        }

                                        delete();
                                      },
                                      child: const Text('Yes'),
                                    ),
                                  ],
                                );
                              },
                            );
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                  'Please fill in all fields and upload the supporting quotation image.'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        }
                      },
                      child: const Text('Preview'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ));
  }
}