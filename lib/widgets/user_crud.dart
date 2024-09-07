import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import '../creds.dart';
import '../errors.dart';
import '../widgets/table.dart';

class UserCrud {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  String _selectedAdminForRemoval = 'Select Admin';
  String _selectedMemberForRemoval = 'Select Member';
  TableData tableData = TableData();

  Future<void> adminCrudMenu(BuildContext context) async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final rolesheet = ss.worksheetByTitle('Admins');
    if (rolesheet == null) return;

    // Fetch all names from the 'Admins' sheet (Column A)
    final List<String> adminNames =
        await rolesheet.values.column(1, fromRow: 2);

    // Clear input fields when closing
    void clearFields() {
      _nameController.clear();
      _emailController.clear();
      _contactController.clear();
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Admin Management'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    clearFields();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add Admin Section
                const Text('Add Admin',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Name
                const Text('Name:'),
                const SizedBox(height: 5),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Enter Name'),
                ),
                const SizedBox(height: 10),

                // Email
                const Text('Email:'),
                const SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Enter Email'),
                ),
                const SizedBox(height: 10),

                // Contact Number
                const Text('Contact No.:'),
                const SizedBox(height: 5),
                TextField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Enter Number'),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    addAdmin(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Add Admin',
                      style: TextStyle(color: Colors.white)),
                ),
                const Divider(height: 30),

                // Remove Admin Section
                const Text('Remove Admin',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Dropdown for selecting admin to remove
                const Text('Select Admin to Remove:'),
                const SizedBox(height: 5),
                DropdownButton<String>(
                  value: _selectedAdminForRemoval == 'Select Admin'
                      ? null
                      : _selectedAdminForRemoval,
                  hint: const Text('Select Admin'),
                  items: adminNames.map((String admin) {
                    return DropdownMenuItem<String>(
                      value: admin,
                      child: Text(admin),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    _selectedAdminForRemoval = newValue!;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedAdminForRemoval == 'Select Admin') {
                      ErrorHandling.showErrorDialog(
                          context, 'Please select an admin to remove.');
                    } else {
                      dltAdmin(_selectedAdminForRemoval);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Remove Admin',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> addAdmin(BuildContext context) async {
    final entName = _nameController.text.trim();
    final entEmail = _emailController.text.trim();
    final entNumber = _contactController.text.trim();
    if (entName.isEmpty) {
      ErrorHandling.showErrorDialog(context, 'Please Enter a Name.');
      return;
    } else if (entEmail.isEmpty) {
      ErrorHandling.showErrorDialog(context, 'Please Enter an Email.');
      return;
    } else if (entNumber.isEmpty) {
      ErrorHandling.showErrorDialog(context, 'Please Enter a Phone Number.');
      return;
    }

    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final rolesheet = ss.worksheetByTitle('Admins');
    final loginsheet = ss.worksheetByTitle('Set up login');
    if (rolesheet == null || loginsheet == null) return;

    await rolesheet.values.appendRow([entName, entEmail, "'$entNumber"]);
    await loginsheet.values
        .appendRow([entEmail, '', entName, "'$entNumber", 'Admin']);
  }

  Future<void> dltAdmin(String selectedName) async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final rolesheet = ss.worksheetByTitle('Admins');
    final loginsheet = ss.worksheetByTitle('Set up login');
    if (rolesheet == null || loginsheet == null) return;

    // Find the row number for the selected admin name in the 'Admins' sheet
    final rolesheetNames = await rolesheet.values
        .column(1, fromRow: 2); // Assuming names are in column A
    final rowIndex = rolesheetNames.indexOf(selectedName);

    if (rowIndex != -1) {
      final matchRow = rowIndex + 2; // Account for header row

      // Delete the row in the 'Admins' sheet
      await rolesheet.deleteRow(matchRow);

      // Find and delete the row in the 'Set up login' sheet by admin name
      final loginsheetNames = await loginsheet.values
          .column(3, fromRow: 2); // Assuming names are in column C
      final loginRowIndex = loginsheetNames.indexOf(selectedName);
      if (loginRowIndex != -1) {
        final loginMatchRow = loginRowIndex + 2;
        await loginsheet.deleteRow(loginMatchRow);
      }
    }
  }

  Future<void> memberCrudMenu(BuildContext context) async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final rolesheet = ss.worksheetByTitle('Committee Members');
    if (rolesheet == null) return;

    // Fetch all names from the 'Members' sheet (Column A)
    final List<String> memberNames =
        await rolesheet.values.column(1, fromRow: 2);

    // Clear input fields when closing
    void clearFields() {
      _nameController.clear();
      _emailController.clear();
      _contactController.clear();
    }

    if (context.mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Committee Member Management'),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    clearFields();
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Add Member Section
                const Text('Add Committee Member',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Name
                const Text('Name:'),
                const SizedBox(height: 5),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Enter Name'),
                ),
                const SizedBox(height: 10),

                // Email
                const Text('Email:'),
                const SizedBox(height: 5),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Enter Email'),
                ),
                const SizedBox(height: 10),

                // Contact Number
                const Text('Contact No.:'),
                const SizedBox(height: 5),
                TextField(
                  controller: _contactController,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      fillColor: Colors.white,
                      filled: true,
                      hintText: 'Enter Number'),
                  keyboardType: TextInputType.number,
                  maxLength: 10,
                ),
                const SizedBox(height: 10),

                ElevatedButton(
                  onPressed: () {
                    addMember(context);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  child: const Text('Add Member',
                      style: TextStyle(color: Colors.white)),
                ),
                const Divider(height: 30),

                // Remove Member Section
                const Text('Remove Committee Member',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                // Dropdown for selecting member to remove
                const Text('Select Member to Remove:'),
                const SizedBox(height: 5),
                DropdownButton<String>(
                  value: _selectedMemberForRemoval == 'Select Member'
                      ? null
                      : _selectedMemberForRemoval,
                  hint: const Text('Select Member'),
                  items: memberNames.map((String member) {
                    return DropdownMenuItem<String>(
                      value: member,
                      child: Text(member),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    _selectedMemberForRemoval = newValue!;
                  },
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    if (_selectedMemberForRemoval == 'Select Member') {
                      ErrorHandling.showErrorDialog(
                          context, 'Please select a member to remove.');
                    } else {
                      dltMember(_selectedMemberForRemoval);
                    }
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  child: const Text('Remove Member',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Future<void> addMember(BuildContext context) async {
    final entName = _nameController.text.trim();
    final entEmail = _emailController.text.trim();
    final entNumber = _contactController.text.trim();
    if (entName.isEmpty) {
      ErrorHandling.showErrorDialog(context, 'Please Enter a Name.');
      return;
    } else if (entEmail.isEmpty) {
      ErrorHandling.showErrorDialog(context, 'Please Enter an Email.');
      return;
    } else if (entNumber.isEmpty) {
      ErrorHandling.showErrorDialog(context, 'Please Enter a Phone Number.');
      return;
    }

    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final rolesheet = ss.worksheetByTitle('Committee Members');
    final loginsheet = ss.worksheetByTitle('Set up login');
    if (rolesheet == null || loginsheet == null) return;

    await rolesheet.values.appendRow([entName, entEmail, "'$entNumber"]);
    await loginsheet.values
        .appendRow([entEmail, '', entName, "'$entNumber", 'Committee Member']);
  }

  Future<void> dltMember(String selectedName) async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final rolesheet = ss.worksheetByTitle('Committee Members');
    final loginsheet = ss.worksheetByTitle('Set up login');
    if (rolesheet == null || loginsheet == null) return;

    // Find the row number for the selected admin name in the 'Committee Members' sheet
    final rolesheetNames = await rolesheet.values
        .column(1, fromRow: 2); // Assuming names are in column A
    final rowIndex = rolesheetNames.indexOf(selectedName);

    if (rowIndex != -1) {
      final matchRow = rowIndex + 2; // Account for header row

      // Delete the row in the 'Committee Members' sheet
      await rolesheet.deleteRow(matchRow);

      // Find and delete the row in the 'Set up login' sheet by member name
      final loginsheetNames = await loginsheet.values
          .column(3, fromRow: 2); // Assuming names are in column C
      final loginRowIndex = loginsheetNames.indexOf(selectedName);
      if (loginRowIndex != -1) {
        final loginMatchRow = loginRowIndex + 2;
        await loginsheet.deleteRow(loginMatchRow);
      }
    }
  }
}