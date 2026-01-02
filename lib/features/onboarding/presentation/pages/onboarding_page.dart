import 'package:flutter/material.dart';
import 'package:tripmates/features/auth/presentation/pages/login_page.dart';
import 'package:tripmates/features/dashboard/presentation/widgets/onboarding_widget.dart';
import 'package:tripmates/features/dashboard/presentation/widgets/my_button.dart';


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  bool isLastPage = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final w = size.width;

    final bottomSpacing = w * 0.04;
    final bottomPadding = EdgeInsets.symmetric(horizontal: w * 0.05);
    final buttonFontSize = w * 0.04;
    

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  isLastPage = (index == 3);
                });
              },
              children: const [
                OnBoardingWidget(
                  image: 'assets/images/image_1.png',
                  title: 'Welcome to TripMates',
                  subtitle: 'Plan, share and enjoy trips with friends.',
                ),
                OnBoardingWidget(
                  image: 'assets/images/image_2.png',
                  title: 'Split Costs Easily',
                  subtitle: 'Settle expenses and share costs with members.',
                ),
                OnBoardingWidget(
                  image: 'assets/images/image_3.png',
                  title: 'Stay Organized',
                  subtitle: 'Itineraries, tasks and reminders in one place.',
                ),
                OnBoardingWidget(
                  image: 'assets/images/image_4.png',
                  title: 'Make Every Trip Better',
                  subtitle: 'Discover, connect, and travel together.',
                ),
              ],
            ),

            Positioned(
              bottom: bottomSpacing,
              left: 0,
              right: 0,
              child: Padding(
                padding: bottomPadding,
                child: isLastPage
                    ? PrimaryButtonWidget(
                        text: "Get Started",
                        onPressed: () {
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const Loginpage(),
                            ),
                          );
                        },
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () {
                              _pageController.animateToPage(
                                3,
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontFamily: "Oswald SemiBold",
                                color: Colors.grey,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          

                          GestureDetector(
                            onTap: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 400),
                                curve: Curves.easeInOut,
                              );
                            },
                            child: Text(
                              "Next",
                              style: TextStyle(
                                fontSize: buttonFontSize,
                                fontFamily: "Oswald SemiBold",
                                color: const Color(0xFF4636F2),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
