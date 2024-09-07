import '../screens/login.dart';
import '../widgets/table.dart';
import 'package:flutter/material.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/user_crud.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  LoginScreenState route = LoginScreenState();
  TableData tableData = TableData();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    refreshAdmin();
    refreshMember(); // Initialize data fetch
  }

  Future<void> refreshAdmin() async {
    final adminData = await tableData.fetchAdminData();
    setState(() {
      tableData.allAdminRows = adminData;
    });
  }

  Future<void> refreshMember() async {
    final committeeData = await tableData.fetchCommitteeData();
    setState(() {
      tableData.allCommitteeRows = committeeData;
    });
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Log Out'),
          content: const Text('Are you sure you want to log out?'),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                Navigator.of(context)
                    .pushReplacementNamed('/login'); // Navigate to login screen
              },
              child: const Text(
                'Yes',
                style: TextStyle(color: Colors.white),
              ),
            ),
            TextButton(
              style: TextButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text(
                'No',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        onLogout: () => _showLogoutDialog(context),
      ),
      backgroundColor: const Color(0xFFD0E4CC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Admin Details Section
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Admin Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                              onPressed: () async {
                                setState(() {
                                  isLoading =
                                      true; // Start loading when refresh is clicked
                                });

                                try {
                                  await refreshAdmin(); // Call the refresh function
                                } catch (e) {
                                  print('Error refreshing data: $e');
                                } finally {
                                  setState(() {
                                    isLoading = false; // Stop loading when done
                                  });
                                }
                              },
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : const Text(
                                      'Refresh',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ),
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                              onPressed: () {
                                UserCrud userCrud = UserCrud();
                                userCrud.adminCrudMenu(context);
                              },
                              child: const Text('Add/Remove',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<DataRow>>(
                    future: tableData.fetchAdminData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      return DataTable(
                        columnSpacing: 5,
                        columns: const [
                          DataColumn(
                            label: SizedBox(
                              width: 200,
                              child: Text('Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 300,
                              child: Text('Email',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 125,
                              child: Text('Contact Number',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                        ],
                        rows: tableData.allAdminRows,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: () {
                          // Handle page navigation
                        },
                      ),
                      const Text('Page 1 of 1'),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: () {
                          // Handle page navigation
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Committee Member Details Section
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Committee Member Details',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                              onPressed: () async {
                                setState(() {
                                  isLoading =
                                      true; // Start loading when refresh is clicked
                                });

                                try {
                                  await refreshMember(); // Call the refresh function
                                } catch (e) {
                                  print('Error refreshing data: $e');
                                } finally {
                                  setState(() {
                                    isLoading = false; // Stop loading when done
                                  });
                                }
                              },
                              child: isLoading
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2.0,
                                      ),
                                    )
                                  : const Text(
                                      'Refresh',
                                      style: TextStyle(color: Colors.white),
                                    ),
                            ), // Refresh action
                            const SizedBox(width: 8),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueAccent,
                              ),
                              onPressed: () {
                                UserCrud userCrud = UserCrud();
                                userCrud.memberCrudMenu(context);
                              },
                              child: const Text('Add/Remove',
                                  style: TextStyle(color: Colors.white)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  FutureBuilder<List<DataRow>>(
                    future: tableData.fetchCommitteeData(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      } else if (snapshot.hasError) {
                        return Center(child: Text('Error: ${snapshot.error}'));
                      }
                      return DataTable(
                        columnSpacing: 5,
                        columns: const [
                          DataColumn(
                            label: SizedBox(
                              width: 200,
                              child: Text('Name',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 300,
                              child: Text('Email',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                          DataColumn(
                            label: SizedBox(
                              width: 125,
                              child: Text('Contact Number',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black)),
                            ),
                          ),
                        ],
                        rows: tableData.allCommitteeRows,
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_left),
                        onPressed: () {
                          // Handle page navigation
                        },
                      ),
                      const Text('Page 1 of 1'),
                      IconButton(
                        icon: const Icon(Icons.arrow_right),
                        onPressed: () {
                          // Handle page navigation
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
