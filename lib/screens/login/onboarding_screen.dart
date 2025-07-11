import 'package:flutter/material.dart';
import 'package:habit_builder/common/color_extensions.dart';
import 'package:habit_builder/screens/login/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  PageController controller = PageController();
  int selectPage = 0;

  List pageArr = [
    {
      "img": "assets/img/splash_1.png",
      "title": "WELCOME TO MONUMENTAL HABITS",
      "subtitle": "We can help you to be a better version of yourself",
    },
    {
      "img": "assets/img/splash_2.png",
      "title": "CREATE NEW HABIT EASILY",
      "subtitle": "Unlock your potential, one simple step at a time",
    },
    {
      "img": "assets/img/splash_3.png",
      "title": "KEEP TRACK OF YOUR PROGRESS",
      "subtitle": "Celebrate your wins and watch your consistency grow",
    },
    {
      "img": "assets/img/splash_4.png",
      "title": "JOIN A SUPPORTIVE COMMUNITY",
      "subtitle": "Achieve your goals together with like-minded people",
    },
  ];

  @override
  Widget build(BuildContext context) {
    bool isLastPage = selectPage == pageArr.length - 1;

    return Scaffold(
      backgroundColor: AppColor.bg,
      body: Stack(
        children: [
          // PageView for content (title, image, subtitle)
          // Wrapped in SafeArea to avoid system overlays
          Padding(
            padding: EdgeInsets.only(
              top:
                  MediaQuery.of(context).padding.top +
                  50, // Keep space for top if needed for other elements
              bottom:
                  30, // Add bottom padding to make space for the new bottom row
            ),
            child: PageView.builder(
              controller: controller,
              itemCount: pageArr.length,
              onPageChanged: (page) {
                setState(() {
                  selectPage = page;
                });
              },
              itemBuilder: (context, index) {
                var obj = pageArr[index];

                return Column(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .start, // Align content from the top of its padded area
                  crossAxisAlignment:
                      CrossAxisAlignment
                          .center, // Center the content horizontally
                  children: [
                    // Title
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: Text(
                        obj["title"].toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColor.primaryText,
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    // Image
                    Image.asset(obj["img"], width: context.width * 0.85),
                    const SizedBox(height: 10),
                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: _buildColoredSubtitle(
                          obj["subtitle"],
                        ), // Use the helper function here
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          Positioned(
            bottom: 150,
            left: 20,
            right: 20,
            child:
                isLastPage
                    ? // If it's the last page, show the "Get Started" button
                    Center(
                      child: InkWell(
                        onTap: () {
                          actionNextScreen();
                        },
                        child: Container(
                          width: context.width * 0.8,
                          height: 50,
                          decoration: BoxDecoration(
                            color: AppColor.primary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            "Get Started",
                            style: TextStyle(
                              color: AppColor.primaryText,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    )
                    : Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        InkWell(
                          onTap: () {
                            actionNextScreen();
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Skip",
                              style: TextStyle(
                                color: AppColor.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),

                        // Dots Indicator (Center)
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            pageArr.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              height: 8,
                              width:
                                  selectPage == index
                                      ? 24
                                      : 8, // Wider for selected dot
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color:
                                    selectPage == index
                                        ? AppColor.primaryText
                                        : AppColor.primary,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),

                        // Next Button (Right)
                        InkWell(
                          onTap: () {
                            if (selectPage < pageArr.length - 1) {
                              setState(() {
                                selectPage += 1;
                                controller.animateToPage(
                                  selectPage,
                                  duration: const Duration(milliseconds: 400),
                                  curve: Curves.easeOut,
                                );
                              });
                            } else {
                              actionNextScreen();
                            }
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Text(
                              "Next",
                              style: TextStyle(
                                color: AppColor.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
          ),
        ],
      ),
    );
  }

  void actionNextScreen() {
    context.push(LoginScreen());
  }

  // Helper function to create colored subtitle TextSpan
  TextSpan _buildColoredSubtitle(String subtitle) {
    // Convert to uppercase once at the beginning if desired
    final words = subtitle.toUpperCase().split(' ');
    final List<TextSpan> spans = [];

    // Define a general style for the subtitle
    TextStyle defaultStyle = TextStyle(
      color: AppColor.primary,
      fontSize: 18,
      fontWeight: FontWeight.w600,
    );

    // Define a highlight style
    TextStyle highlightStyle = TextStyle(
      color:
          AppColor
              .primaryText, // Example highlight color, use AppColor.secondary or AppColor.accent
      fontSize: 18,
      fontWeight: FontWeight.w800, // Make highlighted words bolder
    );

    // Define specific words/phrases to highlight for each subtitle
    // This is the crucial part you'll need to customize based on your content.
    // For a more robust solution, you might add a "highlight_words" list
    // to your `pageArr` map for each subtitle.
    final Map<String, List<String>> highlightMap = {
      "WE CAN HELP YOU TO BE A BETTER VERSION OF YOURSELF": [
        "WE CAN, BETTER VERSION OF",
      ],
      "UNLOCK YOUR POTENTIAL, ONE SIMPLE STEP AT A TIME": [
        "UNLOCK YOUR POTENTIAL",
        "AT A TIME",
      ],
      "CELEBRATE YOUR WINS AND WATCH YOUR CONSISTENCY GROW": [
        "CELEBRATE YOUR WINS",
        "CONSISTENCY GROW",
      ],
      "ACHIEVE YOUR GOALS TOGETHER WITH LIKE-MINDED PEOPLE": [
        "ACHIEVE YOUR GOALS",
        "LIKE-MINDED PEOPLE",
      ],
    };

    // Get the highlight phrases for the current subtitle
    List<String> currentHighlights = highlightMap[subtitle.toUpperCase()] ?? [];

    for (int i = 0; i < words.length; i++) {
      String word = words[i];
      TextStyle currentWordStyle = defaultStyle;

      // Check if the current word (or a phrase starting with it) should be highlighted
      bool isHighlighted = false;
      for (String highlightPhrase in currentHighlights) {
        if (subtitle.toUpperCase().contains(highlightPhrase) &&
            subtitle
                .toUpperCase()
                .substring(subtitle.toUpperCase().indexOf(highlightPhrase))
                .startsWith(words.sublist(i).join(' '))) {
          isHighlighted = true;
          break;
        }
        // More specific check for single words within a phrase if needed
        if (highlightPhrase.split(' ').contains(word)) {
          isHighlighted = true;
          break;
        }
      }

      if (isHighlighted) {
        currentWordStyle = highlightStyle;
      }

      // Add the word (and a space if not the last word)
      spans.add(TextSpan(text: word, style: currentWordStyle));
      if (i < words.length - 1) {
        spans.add(TextSpan(text: ' ', style: defaultStyle));
      }
    }

    return TextSpan(children: spans);
  }
}
