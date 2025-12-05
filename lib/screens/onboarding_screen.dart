import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}


class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> onboardingData = [
    {
      "image": "assets/images/image_1.jpg",
      "title": "Find Your Destination",
      "subtitle":
          "All tourist destinations are in your hands, just click and find convenience."
    },
    {
      "image": "assets/images/image_2.jpg",
      "title": "Start Your Journey",
      "subtitle":
          "From this moment, your amazing and diverse journey begins with one click."
    },
    {
      "image": "assets/images/image_3.png",
      "title": "Travel The World",
      "subtitle":
          "Explore different places and discover surprises always by your side."
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) {
                  setState(() => _currentIndex = index);
                },
                itemCount: onboardingData.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),

                        /// Image
                        Image.asset(
                          onboardingData[index]["image"]!,
                          height: 300,
                        ),

                        const SizedBox(height: 20),

                        /// Title
                        Text(
                          onboardingData[index]["title"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),

                        const SizedBox(height: 12),

                        /// Subtitle
                        Text(
                          onboardingData[index]["subtitle"]!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            /// Indicator
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: _currentIndex == index ? 22 : 8,
                  decoration: BoxDecoration(
                    color: Color(0xFF3F51B5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            /// Bottom Buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  /// Left button (Skip or Back)
                  TextButton(
                    onPressed: () {
                      if (_currentIndex == 0) return;
                      _controller.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    child: Text(
                      _currentIndex == 0 ? "Skip" : "Back",
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFF3F51B5),
                      ),
                    ),
                  ),

                  /// Right button (Next or Login)
                  ElevatedButton(
                    onPressed: () {
                      if (_currentIndex == 2) {
                        /// Navigate to Login
                        Navigator.pushNamed(context, "/login");
                        return;
                      }

                      _controller.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF3F51B5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 28),
                    ),
                    child: Text(
                      _currentIndex == 2 ? "Login" : "Next",
                      style: const TextStyle(
                          fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
// import 'package:flutter/material.dart';

// class OnboardingScreen extends StatefulWidget {
//   const OnboardingScreen({super.key});

//   @override
//   State<OnboardingScreen> createState() => _OnboardingScreenState();
// }

// class _OnboardingScreenState extends State<OnboardingScreen> {

//   final PageController controller = PageController();
//   int page = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [

//           Expanded(
//             child: PageView(
//               controller: controller,
//               onPageChanged: (value) {
//                 setState(() {
//                   page = value;
//                 });
//               },
//               children: [
//                 onboardingPage("assets/images/image_1.jpg", "Find New Travel Mates"),
//                 onboardingPage("assets/images/image_2.jpg", "Plan Budget Trips"),
//                 onboardingPage("assets/images/image_3.jpg", "Travel Smart & Easy"),
//               ],
//             ),
//           ),

//           Padding(
//             padding: const EdgeInsets.only(bottom: 30),
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xff7A33FF),
//                 padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 14),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               onPressed: () {
//                 if (page == 2) {
//                   Navigator.pushReplacementNamed(context, '/login');
//                 } else {
//                   controller.nextPage(
//                     duration: const Duration(milliseconds: 400),
//                     curve: Curves.easeIn,
//                   );
//                 }
//               },
//               child: Text(
//                 page == 2 ? "Login" : "Next",
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           )
//         ],
//       ),
//     );
//   }

//   Widget onboardingPage(String image, String title) {
//     return Stack(
//       children: [

//         /// FULLSCREEN IMAGE
//         Positioned.fill(
//           child: Image.asset(
//             image,
//             fit: BoxFit.cover,
//           ),
//         ),

//         /// TEXT ON BOTTOM
//         Positioned(
//           bottom: 200,
//           left: 20,
//           right: 20,
//           child: Text(
//             title,
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//               color: Color.fromARGB(255, 236, 213, 39),
//               shadows: [
//                 Shadow(
//                   blurRadius: 8,
//                   color: Colors.black54,
//                   offset: Offset(2, 2),
//                 )
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// }

