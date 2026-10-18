import 'package:flutter/material.dart';
import 'package:habit_builder/common/color_extensions.dart';
import 'package:habit_builder/screens/login/login_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final FocusNode _userNameFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();
  final FocusNode _confirmPasswordFocusNode = FocusNode();

  final bool _isLoading = false;
  bool _obscurePassword = true;
  final bool _obscureConfirmPassword = true;

  bool _isUserNameFocused = false;
  bool _isEmailFocused = false;
  bool _isPasswordFocused = false;
  bool _isConfirmPasswordFocused = false;

  bool _keepMeSignedIn = false;
  bool _emailMeDetails = false;

  @override
  void initState() {
    super.initState();

    _userNameFocusNode.addListener(_onUserNameFocusChange);
    _emailFocusNode.addListener(_onEmailFocusChange);
    _passwordFocusNode.addListener(_onPasswordFocusChange);
    _confirmPasswordFocusNode.addListener(_onConfirmPasswordFocusChange);
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _userNameFocusNode.removeListener(_onUserNameFocusChange);
    _userNameFocusNode.dispose();

    _emailController.dispose();
    _emailFocusNode.removeListener(_onEmailFocusChange);
    _emailFocusNode.dispose();

    _passwordController.dispose();
    _passwordFocusNode.removeListener(_onPasswordFocusChange);
    _passwordFocusNode.dispose();

    _confirmPasswordController.dispose();
    _confirmPasswordFocusNode.removeListener(_onConfirmPasswordFocusChange);
    _confirmPasswordFocusNode.dispose();
    super.dispose();
  }

  void _onUserNameFocusChange() {
    setState(() {
      _isUserNameFocused = _userNameFocusNode.hasFocus;
    });
  }

  void _onEmailFocusChange() {
    setState(() {
      _isEmailFocused = _emailFocusNode.hasFocus;
    });
  }

  void _onPasswordFocusChange() {
    setState(() {
      _isPasswordFocused = _passwordFocusNode.hasFocus;
    });
  }

  void _onConfirmPasswordFocusChange() {
    setState(() {
      _isConfirmPasswordFocused = _confirmPasswordFocusNode.hasFocus;
    });
  }

  // Helper to get the color based on focus
  Color _getIconColor(bool isFocused) {
    return isFocused ? AppColor.primary : Colors.black12;
  }

  TextStyle _getLabelHintTextStyle(bool isFocused) {
    return TextStyle(color: isFocused ? AppColor.primary : Colors.black12);
  }

  Widget _buildPrefixIconWithDivider({
    required IconData iconData,
    required bool isFocused,
    bool showDivider = true,
  }) {
    Color iconColor = _getIconColor(isFocused);
    Color dividerColor = Colors.black12;

    return Row(
      mainAxisSize: MainAxisSize.min, // Keep the row compact
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
          ), // Padding around the icon
          child: Icon(iconData, color: iconColor, size: 24),
        ),
        if (showDivider) // Conditionally show the divider
          Container(height: 60, width: 1, color: dividerColor),
        const SizedBox(
          width: 8,
        ), // Small space after divider before text input starts
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.bgSecondary,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: context.height * 0.05),

                //ImageTop
                Image.asset(
                  "assets/img/create_account_ic.png",
                  width: context.width * 0.75,
                  height: context.height * 0.30,
                  fit: BoxFit.contain,
                ),

                SizedBox(height: context.height * 0.03),

                //Title Text
                Text(
                  "CREATE YOUR ACCOUNT",
                  style: TextStyle(
                    color: AppColor.primaryText,
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                  ),
                ),

                SizedBox(height: context.height * 0.05),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _userNameController,
                          focusNode: _userNameFocusNode,
                          style: TextStyle(
                            color: AppColor.primary,
                          ), // Text typed by user
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelStyle: _getLabelHintTextStyle(
                              _isUserNameFocused,
                            ),
                            hintText: "Name",
                            hintStyle: _getLabelHintTextStyle(
                              _isUserNameFocused,
                            ),
                            prefixIcon: _buildPrefixIconWithDivider(
                              iconData: Icons.person_outline,
                              isFocused: _isUserNameFocused,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter username";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),

                        //Email
                        TextFormField(
                          controller: _emailController,
                          focusNode: _emailFocusNode,
                          style: TextStyle(color: AppColor.primary),
                          keyboardType: TextInputType.emailAddress,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelStyle: _getLabelHintTextStyle(_isEmailFocused),
                            hintText: "Email",
                            hintStyle: _getLabelHintTextStyle(_isEmailFocused),
                            prefixIcon: _buildPrefixIconWithDivider(
                              iconData: Icons.email_outlined,
                              isFocused: _isEmailFocused,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none, // No border line
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none, // No border line
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none, // No border line
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter your email";
                            }
                            if (!RegExp(
                              r'^[^@]+@[^@]+\.[^@]+',
                            ).hasMatch(value)) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        //Password
                        TextFormField(
                          controller: _passwordController,
                          focusNode: _passwordFocusNode,
                          style: TextStyle(color: AppColor.primary),
                          obscureText: _obscurePassword,
                          keyboardType: TextInputType.text,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelStyle: _getLabelHintTextStyle(
                              _isPasswordFocused,
                            ),
                            hintText: "Password",
                            hintStyle: _getLabelHintTextStyle(
                              _isPasswordFocused,
                            ),
                            prefixIcon: _buildPrefixIconWithDivider(
                              iconData: Icons.lock_outline_rounded,
                              isFocused: _isPasswordFocused,
                            ),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(
                                top: 15.0,
                                right: 12.0,
                              ),
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                                child: Text(
                                  _obscurePassword ? "Show" : "Hide",
                                  style: TextStyle(
                                    color: _getIconColor(_isPasswordFocused),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none, // No border line
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none, // No border line
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none, // No border line
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter password";
                            }

                            if (value.length < 6) {
                              return "Password must be at least 6 characters long";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: _keepMeSignedIn,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _keepMeSignedIn = newValue ?? false;
                                  });
                                },
                                activeColor: AppColor.primary,
                                checkColor: AppColor.primaryText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(
                                  color: AppColor.primaryText.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _keepMeSignedIn = !_keepMeSignedIn;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    "Keep me signed in",
                                    style: TextStyle(
                                      color: AppColor.primaryText.withOpacity(
                                        0.8,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Transform.scale(
                              scale: 1.2,
                              child: Checkbox(
                                value: _emailMeDetails,
                                onChanged: (bool? newValue) {
                                  setState(() {
                                    _emailMeDetails = newValue ?? false;
                                  });
                                },
                                activeColor: AppColor.primary,
                                checkColor: AppColor.primaryText,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                side: BorderSide(
                                  color: AppColor.primaryText.withOpacity(0.5),
                                  width: 1.5,
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _emailMeDetails = !_emailMeDetails;
                                  });
                                },
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 8.0,
                                  ),
                                  child: Text(
                                    "Email me about special pricing and more",
                                    style: TextStyle(
                                      color: AppColor.primaryText.withOpacity(
                                        0.8,
                                      ),
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 10),

                        // Create Account Button
                        _isLoading
                            ? CircularProgressIndicator(color: AppColor.primary)
                            : ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.primary,
                                minimumSize: Size(context.width * 0.8, 50),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              child: Text(
                                "Creat Account",
                                style: TextStyle(
                                  color: AppColor.primaryText,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                        const SizedBox(height: 20),

                        // OR Divider
                        Row(
                          children: [
                            Expanded(child: Divider(color: Colors.black12)),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8.0,
                              ),
                              child: Text(
                                "Or sign in with",
                                style: TextStyle(color: Colors.black12),
                              ),
                            ),
                            Expanded(child: Divider(color: Colors.black12)),
                          ],
                        ),

                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  print("Sign in with Google");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: Size(0, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.g_mobiledata_rounded,
                                      color: AppColor.primaryText,
                                      size: 28,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      "Google",
                                      style: TextStyle(
                                        color: AppColor.primaryText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(width: 15),

                            Expanded(
                              child: ElevatedButton(
                                onPressed: () {
                                  print("Sign in with Facebook");
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  minimumSize: Size(0, 45),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                      width: 1,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.facebook_outlined,
                                      color: AppColor.primaryText,
                                      size: 23,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      "Facebook",
                                      style: TextStyle(
                                        color: AppColor.primaryText,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        TextButton(
                          onPressed: () {
                            context.push(LoginScreen());
                          },
                          child: RichText(
                            text: TextSpan(
                              text: "Already have an account? ",
                              style: TextStyle(
                                color: AppColor.primaryText.withOpacity(0.7),
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                              ),
                              children: [
                                TextSpan(
                                  text: "Login",
                                  style: TextStyle(
                                    color: AppColor.primaryText,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
