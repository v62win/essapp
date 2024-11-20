import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'colors.dart';
import 'auth.dart';
import 'package:widget_and_text_animator/widget_and_text_animator.dart';
import 'dashboard.dart';

class Onboard extends StatefulWidget {
  const Onboard({super.key});

  @override
  State<Onboard> createState() => _OnboardState();
}

class _OnboardState extends State<Onboard> {
  late PageController _pageViewController;
  int _currentPageIndex = 0;

  void _handlePageViewChanged(int currentPageIndex) {
    setState(() {
      _currentPageIndex = currentPageIndex;
    });
  }

  @override
  void initState() {
    super.initState();
    _pageViewController = PageController();
  }

  @override
  void dispose() {
    _pageViewController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        color: backgroundColor1,
        child: Column(
          children: [
            Expanded(
              child: PageView(
                controller: _pageViewController,
                onPageChanged: _handlePageViewChanged,
                scrollDirection: Axis.horizontal,
                children: [
                  Container(
                    color: backgroundColor1,
                    height: size.height,
                    width: size.width,
                    child: Stack(
                      children: [
                        Positioned(
                          top: size.height * 0.15,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: size.height * 0.43,
                            width: size.width * 0.55,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage("assets/images/college-campus-concept-illustration.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.65,
                          left: 0,
                          right: 0,
                          child: const Center(
                            child: Column(
                              children: [
                                TextAnimator(
                                  "Some text",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 40,
                                    color: Colors.black,
                                    height: 1.2,
                                  ),
                                ),
                                SizedBox(height: 16), // Adding space between texts
                                TextAnimator(
                                  "Some text",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.blueGrey,
                                    height: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: backgroundColor1,
                    height: size.height,
                    width: size.width,
                    child: Stack(
                      children: [
                        Positioned(
                          top: size.height * 0.40,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: size.height * 0.43,
                            width: size.width * 0.55,
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              image: DecorationImage(
                                image: AssetImage("assets/images/hand-with-mobile-face-scan-man.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.15,
                          left: 0,
                          right: 0,
                          child: const Center(
                            child: Column(
                              children: [
                                TextAnimator(
                                  "Some text",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Colors.black,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: backgroundColor1,
                    height: size.height,
                    width: size.width,
                    child: Stack(
                      children: [
                        Positioned(
                          top: size.height * 0.15,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: size.height * 0.43,
                            width: size.width * 0.55,
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(50)),
                              color: Colors.white,
                              image: DecorationImage(
                                image: AssetImage("assets/images/giant-checklist.png"),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.65,
                          left: 0,
                          right: 0,
                          child: const Center(
                            child: Column(
                              children: [
                                TextAnimator(
                                  "Some text",
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                    color: Colors.black,
                                    height: 1.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          top: size.height * 0.75,
                          left: size.height * 0.09,
                          right: size.height * 0.09,
                          child: ElevatedButton(
                            onPressed: (){
                              Navigator.push(context, MaterialPageRoute(builder: (context) =>  Auth()));
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white, backgroundColor: primaryColor, // Text color
                              shadowColor: primaryColor,
                              elevation: 10,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 15.0),
                            ),
                            child: Text(
                              'Get Started',
                              style: TextStyle(fontSize: 25),
                            ),
                          )
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SmoothPageIndicator(
              controller: _pageViewController,
              count: 3,
              effect: const WormEffect(
                dotHeight: 12.0,
                dotWidth: 12.0,
                activeDotColor: Colors.blue,
                dotColor: Colors.grey,
              ),
            ),
            const SizedBox(height: 16), // Adding some space at the bottom
          ],
        ),
      ),
    );
  }
}
