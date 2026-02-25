import 'package:flutter/material.dart';
import 'package:zybo_expense_tracker/core/theme/app_colors.dart';
import 'package:zybo_expense_tracker/core/theme/app_text_styles.dart';
import '../models/walkthrough_data.dart';
import 'package:zybo_expense_tracker/features/auth/screens/login_screen.dart';

class WalkthroughScreen extends StatefulWidget {
  const WalkthroughScreen({super.key});

  @override
  State<WalkthroughScreen> createState() => _WalkthroughScreenState();
}

class _WalkthroughScreenState extends State<WalkthroughScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<WalkthroughData> _pages = [
    WalkthroughData(
      title: 'Privacy by Default, With Zero Ads or Hidden Tracking',
      description: 'No ads. No trackers. No third-party analytics.',
      imagePath: 'assets/images/splash_1.png',
    ),
    WalkthroughData(
      title: 'Insights That Help You Spend Better Without Complexity',
      description: 'See category-wise spending, recent activity.',
      imagePath: 'assets/images/splash_1.png',
    ),
    WalkthroughData(
      title: 'Local-First Tracking That Stays Fully On Your Device',
      description: 'Your finances stay on your phone.',
      imagePath: 'assets/images/splash_1.png',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentIndex < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  void _previousPage() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Positioned.fill(
            child: PageView.builder(
              controller: _pageController,
              itemCount: _pages.length,
              onPageChanged: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              itemBuilder: (context, index) {
                return Image.asset(
                  _pages[index].imagePath,
                  fit: BoxFit.cover,
                  width: double.infinity,
                );
              },
            ),
          ),

          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.35),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.8),
                      Colors.black,
                    ],
                    stops: const [0.5, 0.75, 1.0],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 8.0,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (_currentIndex < 2)
                        TextButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              2,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: SizedBox(
                            width: 35,
                            height: 12,
                            child: Text(
                              'SKIP',
                              textAlign: TextAlign.right,
                              style: AppTextStyles.buttonText.copyWith(
                                fontSize: 16,
                                height: 1.0,
                                letterSpacing: -0.03 * 16,
                              ),
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 48),
                    ],
                  ),
                ),

                const Spacer(),

                IgnorePointer(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: List.generate(
                            _pages.length,
                            (i) => Expanded(
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                margin: EdgeInsets.only(
                                  right: i == _pages.length - 1 ? 0 : 8,
                                ),
                                height: 4,
                                decoration: BoxDecoration(
                                  color: _currentIndex == i
                                      ? AppColors.textPrimary
                                      : AppColors.textPrimary.withValues(
                                          alpha: 0.3,
                                        ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        Text(
                          _pages[_currentIndex].title,
                          style: AppTextStyles.title,
                        ),
                        const SizedBox(height: 12),

                        Text(
                          _pages[_currentIndex].description,
                          style: AppTextStyles.description,
                        ),
                      ],
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      if (_currentIndex > 0) ...[
                        Container(
                          height: 56,
                          width: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: AppColors.textSecondary.withValues(
                                alpha: 0.3,
                              ),
                              width: 1,
                            ),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: AppColors.textPrimary,
                            ),
                            onPressed: _previousPage,
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],

                      Expanded(
                        child: SizedBox(
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.textPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _currentIndex == _pages.length - 1
                                  ? 'Get Started'
                                  : 'Next',
                              style: AppTextStyles.buttonText,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
