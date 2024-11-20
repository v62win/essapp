import 'dart:convert';
import 'dart:io';
import 'package:fl_chart/fl_chart.dart';
import 'manageleaves.dart';
import 'settings.dart';
import 'monthlyattendance.dart';
import 'package:quickalert/quickalert.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:ess_app/common/barchart.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:ess_app/media/media_service_interface.dart';
import 'package:ess_app/perm/service_locator.dart';
import 'package:flutter_advanced_drawer/flutter_advanced_drawer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'colors.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'leave_form.dart';
import 'calendarview.dart';
import 'fullscreen.dart';
import 'package:ess_app/state/shared_preference_services.dart';
import 'check.dart';
import 'package:flutter/services.dart';



ValueNotifier<String?> profileImageNotifier = ValueNotifier<String?>(null);

class Dash extends StatefulWidget {
  const Dash({super.key});

  @override
  State<Dash> createState() => _DashState();
}

class _DashState extends State<Dash> {
  final AdvancedDrawerController _advancedDrawerController = AdvancedDrawerController();
  int _selectedIndex = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadImagePath();
  }

  Future<void> _loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    profileImageNotifier.value = prefs.getString('profileImagePath');
  }

  void _handleMenuButtonPressed() {
    _advancedDrawerController.showDrawer();
  }

  Future<bool> _onWillPop() async {
    if (_selectedIndex != 0) {
      setState(() {
        _selectedIndex = 0;  // Navigate back to the dashboard screen
      });
      return false; // Prevent the default back button behavior
    }
    return true; // Allow the back button to close the app or go to the Auth screen
  }

  Future<void> signOut() async {
    SharedPreferencesService().setLoggedIn(false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('Atoken');
    await prefs.remove('Rtoken');
    await prefs.remove('name');
    await prefs.remove('idemp');
    await prefs.remove('profileImagePath');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Auth()));
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: AdvancedDrawer(
        backdrop: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(color: primaryColor),
        ),
        controller: _advancedDrawerController,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        animateChildDecoration: true,
        rtlOpening: false,
        disabledGestures: false,
        childDecoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
        drawer: SafeArea(
          child: ListTileTheme(
            textColor: Colors.white,
            iconColor: Colors.white,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                ValueListenableBuilder<String?>(
                  valueListenable: profileImageNotifier,
                  builder: (context, imageUrl, child) {
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Zoomimage()),
                        );
                      },
                      child: Container(
                        width: 128.0,
                        height: 128.0,
                        margin: const EdgeInsets.only(
                          top: 24.0,
                          bottom: 64.0,
                        ),
                        clipBehavior: Clip.antiAlias,
                        decoration: const BoxDecoration(
                          color: Colors.black26,
                          shape: BoxShape.circle,
                        ),
                        child: imageUrl != null
                            ? Image.file(File(imageUrl), fit: BoxFit.cover)
                            : Image.asset('assets/images/placeholder.png'),
                      ),
                    );
                  },
                ),
                ListTile(
                  onTap: () {
                    setState(() {
                      _selectedIndex = 0; // Navigate to the dashboard screen
                    });
                    _advancedDrawerController.hideDrawer();
                  },
                  leading: const Icon(Icons.dashboard),
                  title: const Text('Dashboard'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileScreen()));
                  },
                  leading: const Icon(Icons.account_circle_rounded),
                  title: const Text('Profile'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => AttendanceScreen()));
                  },
                  leading: const Icon(Icons.file_copy),
                  title: const Text('Leaves'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Manager()));
                  },
                  leading: const Icon(Icons.manage_accounts),
                  title: const Text('Manager'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => Settings()));
                  },
                  leading: const Icon(Icons.settings),
                  title: const Text('Settings'),
                ),
                ListTile(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => MonthlyAttendance()));
                  },
                  leading: const Icon(Icons.stacked_bar_chart),
                  title: const Text('Attendance'),
                ),
                const Spacer(),
                DefaultTextStyle(
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white54,
                  ),
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      vertical: 16.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Dashboard'), // Set your app bar title directly
            leading: IconButton(
              onPressed: _handleMenuButtonPressed,
              icon: ValueListenableBuilder<AdvancedDrawerValue>(
                valueListenable: _advancedDrawerController,
                builder: (_, value, __) {
                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      value.visible ? Icons.clear : Icons.menu,
                      key: ValueKey<bool>(value.visible),
                    ),
                  );
                },
              ),
            ),
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: const [
              DashboardScreen(),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {

  var username;
  var empid;


  Setemployee() async {
    final prefs = await SharedPreferences.getInstance();
    // Perform the async operations outside of setState
    String? name = prefs.getString('name');
    String? id = prefs.getString('idemp');

    // Then update the state synchronously
    setState(() {
      username = name;
      empid = id;
    });

    print(username);
  }


  Future<void> signOut() async {
    SharedPreferencesService().setLoggedIn(false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('Atoken');
    await prefs.remove('Rtoken');
    await prefs.remove('name');
    await prefs.remove('idemp');
    await prefs.remove('profileImagePath');
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const Auth()));
  }


  @override
  void initState() {
    super.initState();
    Setemployee();
  }



  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ValueListenableBuilder<String?>(
                      valueListenable: profileImageNotifier,
                      builder: (context, imageUrl, child) {
                        return CircleAvatar(
                          radius: 45,
                          backgroundImage: imageUrl != null
                              ? FileImage(File(imageUrl))
                              : const AssetImage('assets/images/placeholder.png') as ImageProvider,
                        );
                      },
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '$username',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 20),
                Text(
                  'Attendance Summary',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 30,
                    color: Colors.black,
                  ),
                ),
                /*SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTabButton('', false),
                  _buildTabButton('', false),
                  _buildTabButton('', false),
                ],
              ),*/
                SizedBox(height: 20),
                StaggeredGrid.count(
                  crossAxisCount: 4,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    // Pie Chart Tile
                    StaggeredGridTile.count(
                      crossAxisCellCount: 4,
                      mainAxisCellCount: 3,
                      child: AnimatedBarChart(
                        attendanceValues: [1.0, 0.5, 0.0, 1.0, 0.5, 1.0, 0.0], // Example values for 7 days
                      ),
                    ),


                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: _buildInfoCard(
                          context,
                          title: 'Calendar',
                          value: 'Calendar',
                          color: Color(0xff97a6ff),
                          icon: Icons.calendar_month,
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const Calendarview()));
                          }
                      ),
                    ),

                    StaggeredGridTile.count(
                      crossAxisCellCount: 2,
                      mainAxisCellCount: 2,
                      child: _buildInfoCard(
                          context,
                          title: 'Apply Leave',
                          value: 'Apply Leave',
                          color: Color(0xff97a6ff),
                          icon: Icons.description,
                          onTap: (){
                            Navigator.push(context, MaterialPageRoute(builder: (context) => const LeaveForm()));
                          }
                      ),
                    ),
                    StaggeredGridTile.count(
                        crossAxisCellCount: 3,
                        mainAxisCellCount: 1,
                        child: GestureDetector(
                          onTap: (){Navigator.push(context, MaterialPageRoute(builder: (context) => Check()));},
                          child: Card(
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.door_sliding, color: primaryColor, size: 25),
                                  Spacer(),
                                  Text(
                                    'Check in/out',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                    ),
                    StaggeredGridTile.count(
                        crossAxisCellCount: 1,
                        mainAxisCellCount: 1,
                        child: GestureDetector(
                          onTap: (){
                            QuickAlert.show(
                              context: context,
                              type: QuickAlertType.confirm,
                              text: 'Do you want to logout',
                              confirmBtnText: 'Yes',
                              cancelBtnText: 'No',
                              confirmBtnColor: Colors.green,
                              onConfirmBtnTap: (){
                                signOut();

                              },
                              onCancelBtnTap: (){
                                Navigator.pop(context);
                              },


                            );


                          },
                          child: Card(
                            color: Colors.white,
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(Icons.logout, color: Colors.red, size: 25),
                                  Spacer(),
                                  Text(
                                    '',
                                    style: TextStyle(
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold,
                                      color: primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                    )
                  ],
                ),
              ],
            ),
          ),
        )



    );





  }

  Widget _buildTabButton(String title, bool isSelected) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.grey[200],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
  Widget _buildInfoCard(
      BuildContext context, {
        required String title,
        required String value,
        required Color color,
        required IconData icon,
        required VoidCallback onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 5,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 25),
              Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final MediaServiceInterface _mediaService = getIt<MediaServiceInterface>();

  bool _isLoading = false;
  var username;
  String empid = "";

  Setemployee() async {
    final prefs = await SharedPreferences.getInstance();
    // Perform the async operations outside of setState
    String? name = prefs.getString('name');
    String? id = prefs.getString('idemp');

    // Then update the state synchronously
    setState(() {
      username = name;
      empid = id!;
    });

    print(username);
    print(empid);
  }


  @override
  void initState() {
    super.initState();
    Setemployee();
    _loadImagePath();

  }

  Future<void> updateImage() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? imagePath = prefs.getString('profileImagePath');

      if (imagePath == null) {
        print("No image found in SharedPreferences.");
        return;
      }

      File? imageFile = File(imagePath);

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('API URL'),
      );
      request.files.add(await http.MultipartFile.fromPath('Image', imageFile.path));
      request.fields['action'] = 'UPDATE';
      request.fields['Id'] = '$empid';

      var response = await request.send();
      var responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        setState(() {
          profileImageNotifier.value = imageFile.path;
        });
        showSuccessDialog();
        // Update the ValueNotifier
        // Invalidate the image cache after updating the image
        SystemChannels.platform.invokeMethod('SystemChannels.imageCache.invalidateCache');
      } else {
        showErrorDialog(responseBody.body);
        await _clearImagePath();
        profileImageNotifier.value = null; // Reset the ValueNotifier on error
      }
    } catch (e) {
      print("Error: $e");
      showErrorDialog(e.toString());
      await _clearImagePath();
      profileImageNotifier.value = null; // Reset the ValueNotifier on error
    }
  }

  Future<void> _loadImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPath = prefs.getString('profileImagePath');
    if (savedPath != null) {
      profileImageNotifier.value = savedPath; // Set initial image from saved path
    }
  }

  Future<void> _saveImagePath(String path) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('profileImagePath', path);
    await updateImage(); // Only upload after path is saved
  }

  Future<void> _clearImagePath() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('profileImagePath');
  }

  Future<void> _pickImageSource() async {
    AppImageSource? appImageSource = await showCupertinoModalPopup(
      context: context,
      builder: (BuildContext context) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            child: const Text('Take Photo'),
            onPressed: () => Navigator.of(context).pop(AppImageSource.camera),
          ),
          CupertinoActionSheetAction(
            child: const Text('Upload From Gallery'),
            onPressed: () => Navigator.of(context).pop(AppImageSource.gallery),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text('Cancel'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
    if (appImageSource != null) {
      _getImage(appImageSource);
    }
  }

  Future<void> _getImage(AppImageSource appImageSource) async {
    setState(() => _isLoading = true);
    final pickedImageFile = await _mediaService.uploadImage(context, appImageSource);
    setState(() => _isLoading = false);

    if (pickedImageFile != null) {
      _saveImagePath(pickedImageFile.path); // Save image path and trigger upload
    }
  }

  void showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: const Text('Image uploaded successfully!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void showErrorDialog(String errorMessage) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text('Failed to upload image: $errorMessage'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 20,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Column(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 120),
                  GestureDetector(
                    onTap: _isLoading ? null : _pickImageSource,
                    child: ValueListenableBuilder<String?>(
                      valueListenable: profileImageNotifier,
                      builder: (context, imagePath, _) {
                        return Stack(
                          alignment: Alignment.center,
                          children: [
                            // Background circular progress indicator
                            SizedBox(
                              width: 250, // Increased size for the progress indicator
                              height: 250,
                              child: CircularProgressIndicator(
                                value: 0.7, // Adjust this for progress percentage
                                strokeWidth: 6,
                                backgroundColor: Colors.grey.shade200,
                                color: Colors.blueAccent,
                              ),
                            ),
                            // Profile image
                            Container(
                              width: 200, // Increased size for the profile image
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(width: 2, color: Colors.blueAccent),
                                image: imagePath == null
                                    ? null
                                    : DecorationImage(
                                  image: FileImage(File(imagePath)),
                                  fit: BoxFit.cover,
                                ),
                              ),
                              child: imagePath == null
                                  ? Icon(Icons.person, size: 80, color: Colors.grey) // Increased icon size
                                  : null,
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 26),
                  // Display user information
                  Text(
                    username ?? 'User Name',
                    style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Company Name',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Buttons for actions
                ],
              ),
            ),
          )

        ]
      ),
    );
  }


}




class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen> {
  bool isloading = false ;
  List<dynamic> leaves = []; // Initialize as an empty list
  final RefreshController _refreshController = RefreshController(initialRefresh: false);

  var username ;
  String empid = "" ;

  @override
  void initState() {
    super.initState();
    Setemployee(); // Call Setemployee first, then call leavelist() only when empid is set
  }

  Setemployee() async {
    final prefs = await SharedPreferences.getInstance();
    String? name = prefs.getString('name');
    String? id = prefs.getString('idemp');

    setState(() {
      empid = id!;
    });

    if (empid != null) {
      leavelist();
    }
  }


  Future<void> leavelist() async {
    if (empid == null) {
      print("Employee ID is null, cannot fetch leave list.");
      return;
    }

    setState(() {
      isloading = true;
    });

    try {
      // Encode empid to handle special characters

      var response = await http.get(
        Uri.parse('API URL'),
      );

      if (response.statusCode == 200) {
        var responseJSON = jsonDecode(response.body) as List<dynamic>;
        setState(() {
          leaves = responseJSON.reversed.toList();
          isloading = false;
        });
      } else if (response.statusCode == 401) {
        var responseJSON = jsonDecode(response.body) as Map<String, dynamic>;
        print(responseJSON);
        setState(() {
          isloading = false;
        });
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        isloading = false;
      });
    }
  }



  void _onRefresh() async {
    await leavelist(); // Refresh the data
    _refreshController.refreshCompleted(); // End the refresh
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return   Scaffold(
      appBar: AppBar(
        title: Text(
          'Leave List',
          style: TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 20,
            color: Colors.black,
            height: 1.2,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body:  isloading
          ? const Center(
          child: SpinKitWave(
            color: Color(0xff97a6ff),
            size: 50,
          ))
          :SmartRefresher(
        controller: _refreshController,
        onRefresh: _onRefresh, // Trigger the refresh on pull-down
        child:
        SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Leaves',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        color: Colors.black,
                        height: 1.8,
                      ),
                    ),
                    FloatingActionButton(
                      backgroundColor: primaryColor, // Replace with your primaryColor
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const LeaveForm()),
                        );
                      },
                      child: const Icon(Icons.add, color: Colors.white, size: 30),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(color: Colors.black, width: 0.5),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        FloatingActionButton(
                          elevation: 0,
                          backgroundColor: primaryColor,
                          onPressed: () {},
                          child: const Icon(Icons.beach_access, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 20),
                        if (leaves.isNotEmpty)...[
                          Text(
                            "Balance Leave Days:",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            "${leaves.isNotEmpty ? leaves[0]['balanceLeaves'] : 0}",
                            style: const TextStyle(
                              fontSize: 20,
                              color: Colors.grey,
                            ),
                          ),
                        ]else...[
                          Text(
                            "No Leaves Found",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ListView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                  itemCount: leaves.length,
                  itemBuilder: (context, index) {
                    final leave = leaves[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0), // Space between cards
                      child: GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                contentPadding: const EdgeInsets.all(20),
                                content: SizedBox(
                                  width: size.width * 0.7, // Define the width
                                  height: size.height * 0.3, // Define the height
                                  child: SingleChildScrollView(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the start
                                      children: [
                                        const Text(
                                          "Leave Application Details",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black,
                                          ),
                                        ),
                                        const SizedBox(height: 20),
                                        Row(
                                          children: [
                                            const Text(
                                              "Applied on:",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${leave['createdAt'].split('T').first}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            const Text(
                                              "Applied time:",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${leave['createdAt'].split('T').last}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            const Text(
                                              "Status:",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${leave['statusName']}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          children: [
                                            const Text(
                                              "Approved by:",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Text(
                                              "${leave['approvedBy']}",
                                              style: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 7),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            const Text(
                                              "Description:",
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                "${leave['leaveDescription']}",
                                                style: const TextStyle(
                                                  fontSize: 15,
                                                  color: Colors.grey,
                                                ),
                                                softWrap: true, // Ensures the text will wrap
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if(leave['approvedNoOfDays'] == null)...[
                                  Text(
                                    "Leave Date: ${leave['leaveDate'].split('T').first}\nReturn Date: ${leave['returnDate'].split('T').first}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ]else...[
                                  Text(
                                    " Approved Leave Date: ${leave['approvedLeaveDate'].split('T').first}\n Approved Return Date: ${leave['approvedReturnDate'].split('T').first}",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 10),
                                if(leave['approvedNoOfDays'] == null)...[
                                  Text(
                                    "No of Days: ${leave['noOfDays']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ]else...[
                                  Text(
                                    "No of Days: ${leave['approvedNoOfDays']}",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black54,
                                    ),
                                  ),
                                ],

                                const SizedBox(height: 10),
                                Text(
                                  "Description: ${leave['leaveDescription']}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.black54,
                                  ),
                                ),
                                Align(
                                  alignment: Alignment.bottomRight,
                                  child:  Text(
                                    "${leave['statusName']}",
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight:FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ) ,

                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),


    );


  }
}


