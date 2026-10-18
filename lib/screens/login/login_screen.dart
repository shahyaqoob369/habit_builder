import 'package:flutter/material.dart';
import 'package:habit_builder/common/color_extensions.dart';
import 'package:habit_builder/screens/login/create_account_screen.dart'; // Assuming this is your color extension file

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- Controllers and Keys ---
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;

  // --- State for Focus and Errors ---
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  String? _passwordErrorText; // For handling "Wrong password" error

  @override
  void initState() {
    super.initState();
    // Add listeners to track focus changes
    _emailFocusNode.addListener(_onFocusChange);
    _passwordFocusNode.addListener(_onFocusChange);

    // Add listener to clear password error when user types
    _passwordController.addListener(() {
      if (_passwordErrorText != null) {
        setState(() {
          _passwordErrorText = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();

    _emailFocusNode.removeListener(_onFocusChange);
    _passwordFocusNode.removeListener(_onFocusChange);
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _isEmailFocused = _emailFocusNode.hasFocus;
      _isPasswordFocused = _passwordFocusNode.hasFocus;
    });
  }

  void _login() {
    if (_formKey.currentState?.validate() ?? false) {
      final email = _emailController.text;
      final password = _passwordController.text;

      // --- TODO: Implement your actual authentication logic here ---
      // For demonstration, we'll simulate a wrong password scenario
      if (password != "correct_password") {
        setState(() {
          _passwordErrorText = "Wrong password";
        });
        return; // Stop the login process
      }

      // If login is successful:
      setState(() {
        _passwordErrorText = null; // Clear any previous errors
      });

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Logging in with $email...')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColor.bgSecondary,
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // --- Header Section ---
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: double.infinity,
                  height: screenHeight,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage('assets/img/splash_bg.png'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: screenHeight * 0.3),
                          Text(
                            'WELCOME TO\nMONUMENTAL HABITS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              color: AppColor.primaryText,
                            ),
                          ),
                          const SizedBox(height: 32),
                          // **UPDATED to pass IconData**
                          _SocialLoginButton(
                            text: 'Continue with Google',
                            icon: Icons.g_mobiledata_rounded,
                            onPressed: () {
                              /* TODO */
                            },
                          ),
                          const SizedBox(height: 16),
                          // **UPDATED to pass IconData**
                          _SocialLoginButton(
                            text: 'Continue with Facebook',
                            icon: Icons.facebook,
                            onPressed: () {
                              /* TODO */
                            },
                          ),
                        ],
                      ),
                    ),

                    Container(
                      padding: const EdgeInsets.all(24.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(40.0),
                          topRight: Radius.circular(40.0),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, -2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- Centered title with divider below ---
                          Column(
                            children: [
                              Text(
                                'Log in with email',
                                style: TextStyle(
                                  color: AppColor.secondaryText,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Divider(thickness: 1),
                            ],
                          ),

                          const SizedBox(height: 24),

                          // --- Form ---
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  decoration: _buildInputDecoration(
                                    hintText: 'Jonathan@gmail.com',
                                    prefixIcon: Icons.email_outlined,
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.isEmpty ||
                                        !RegExp(
                                          r'\S+@\S+\.\S+',
                                        ).hasMatch(value)) {
                                      return 'Please enter a valid email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: !_isPasswordVisible,
                                  decoration: _buildInputDecoration(
                                    hintText: 'Password',
                                    prefixIcon: Icons.lock_outline,
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(
                                        top: 15.0,
                                        right: 12.0,
                                      ),
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _isPasswordVisible =
                                                !_isPasswordVisible;
                                          });
                                        },
                                        child: Text(
                                          _isPasswordVisible ? "Show" : "Hide",
                                          style: TextStyle(
                                            color:
                                                _isPasswordFocused
                                                    ? AppColor.primaryText
                                                    : Colors.black12,
                                            fontSize: 14,
                                            fontWeight: FontWeight.normal,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.length < 6) {
                                      return 'Password must be at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 20),

                          // --- Login Button ---
                          ElevatedButton(
                            onPressed: _login,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              minimumSize: Size(context.width * 0.8, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: Text(
                              "Login",
                              style: TextStyle(
                                color: AppColor.primaryText,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),

                          const SizedBox(height: 10),

                          // --- Forgot Password ---
                          TextButton(
                            onPressed: () {
                              /* TODO */
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: AppColor.primaryText,
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ),

                          // --- Sign up link ---
                          TextButton(
                            onPressed: () {
                              context.push(CreateAccountScreen());
                            },
                            child: RichText(
                              text: TextSpan(
                                text: "Don't have an account? ",
                                style: TextStyle(
                                  color: AppColor.primaryText,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Sign up",
                                    style: TextStyle(
                                      color: AppColor.primaryText,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 16,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.question_mark,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        /* TODO */
                      },
                    ),
                  ),
                ),
              ],
            ),

            // --- Form Section on White Background ---
          ],
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration({
    required String hintText,
    required IconData prefixIcon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(prefixIcon, color: AppColor.secondaryText),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: AppColor.primary.withOpacity(0.1),
      contentPadding: const EdgeInsets.all(10),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColor.primary, width: 2),
      ),
    );
  }
}

// **UPDATED to use IconData instead of String iconPath**
class _SocialLoginButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 50),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
          side: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        elevation: 0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // **UPDATED to use Icon widget**
          Icon(icon, color: AppColor.primaryText, size: 28),
          const SizedBox(width: 10),
          Text(
            text,
            style: TextStyle(
              color: AppColor.primaryText,
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
