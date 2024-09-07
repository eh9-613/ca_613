import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import '../creds.dart';

class TableData {
  List<DataRow> allAdminRows = [];
  List<DataRow> allCommitteeRows = [];

  Future<List<DataRow>> fetchAdminData() async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final adminData = ss.worksheetByTitle('Admins');
    if (adminData == null) {
      throw 'Worksheet not found';
    }

    final allAdminRows = await adminData.values.allRows(fromRow: 2);

    return allAdminRows.map<DataRow>((row) {
      return DataRow(cells: [
        DataCell(Text(row[0])), // Name
        DataCell(Text(row[1])), // Email
        DataCell(Text(row[2])), // Contact Number
      ]);
    }).toList();
  }

  Future<List<DataRow>> fetchCommitteeData() async {
    final gsheets = GSheets(credentials);
    final ss = await gsheets.spreadsheet(spreadsheetId);
    final memberData = ss.worksheetByTitle('Committee Members');
    if (memberData == null) {
      throw 'Worksheet not found';
    }
    final allCommitteeRows = await memberData.values.allRows(fromRow: 2);

    return allCommitteeRows.map<DataRow>((row) {
      return DataRow(cells: [
        DataCell(Text(row[0])), // Name
        DataCell(Text(row[1])), // Email
        DataCell(Text(row[2])), // Contact Number
      ]);
    }).toList();
  }
}