import 'package:flutter/material.dart';
import 'package:gsheets/gsheets.dart';
import '../creds.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  final void Function()? onLogout;

  const CustomAppBar({super.key, this.onLogout});

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

class _CustomAppBarState extends State<CustomAppBar> {
  String homeRoute = '/'; // Default route

  @override
  void initState() {
    super.initState();
    _determineHomePage();
  }

  Future<void> _determineHomePage() async {
    try {
      final gsheets = GSheets(credentials);
      final ss = await gsheets.spreadsheet(spreadsheetId);

      // Fetch 'Login History' and get the email from the latest row
      final loginHistorySheet = ss.worksheetByTitle('Login History');
      final loginHistoryRows = await loginHistorySheet?.values.allRows();
      final latestLoginEmail =
          loginHistoryRows?.last[0]; // Assuming column A is Email

      // Fetch 'Set up login' and match the email to get the user role
      final setupSheet = ss.worksheetByTitle('Set up login');
      final setupRows = await setupSheet?.values.allRows();
      if (setupRows != null) {
        for (var row in setupRows) {
          if (row[0] == latestLoginEmail) {
            final userRole = row[4]; // Assuming column E is Role
            setState(() {
              if (userRole == 'Super Admin') {
                homeRoute = '/sAdminHome';
              } else if (userRole == 'Admin') {
                homeRoute = '/adminHome';
              } else if (userRole == 'Committee Member') {
                homeRoute = '/memberHome';
              }
            });
            break;
          }
        }
      }
    } catch (e) {
      print('Error determining home page: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.home, color: Colors.white),
                  label: const Text('Home Page',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pushNamed(context, homeRoute);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.assignment_add, color: Colors.white),
                  label: const Text('Submit Form',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/submitForm');
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.table_rows, color: Colors.white),
                  label: const Text('View Resolutions',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    Navigator.pushNamed(context, '/viewResolutions');
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.logout, color: Colors.white),
                  label: const Text('Log Out',
                      style: TextStyle(color: Colors.white)),
                  onPressed: () {
                    if (widget.onLogout != null) {
                      widget.onLogout!();
                    } else {
                      // Show a confirmation dialog before logging out
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Confirm Logout'),
                            content:
                                const Text('Are you sure you want to log out?'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                },
                                child: const Text('No',
                                    style: TextStyle(color: Colors.red)),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context); // Close the dialog
                                  Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      '/login',
                                      (route) => false); // Navigate to login
                                },
                                child: const Text('Yes',
                                    style: TextStyle(color: Colors.blue)),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      toolbarHeight: 56.0,
    );
  }
}