import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/auth_service.dart';
import 'registration_screen.dart';
import 'main_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // --- ZMIENNE (BEZ ZMIAN) ---
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();

  String? _emailError;    
  String? _generalError;  

  final _authService = AuthService(); 
  bool _isLoading = false;

  @override
  void dispose() {
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isEmailValid(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,6}$');
    return emailRegex.hasMatch(email);
  }

  Future<void> _login() async {
    setState(() {
      _emailError = null;
      _generalError = null;
    });

    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    bool isValid = true;

    if (email.isEmpty) {
      setState(() => _emailError = "Podaj email");
      isValid = false;
    } else if (!_isEmailValid(email)) {
      setState(() => _emailError = "Niepoprawny format emaila");
      isValid = false;
    }

    if (password.isEmpty) {
      setState(() => _generalError = "Uzupełnij wszystkie dane");
      return; 
    }

    if (!isValid) return;

    setState(() => _isLoading = true);

    try {
      final userModel = await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );

      if (userModel != null) {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context) => const MainScreen()),
          );
        }
      } else {
        throw Exception("Błąd logowania.");
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _generalError = "Błędny email lub hasło";
        });
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // --- BUDOWA WIDOKU (NOWA STRUKTURA) ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // To jest FUNDAMENTALNE - blokuje zmiany rozmiaru okna przy klawiaturze
      resizeToAvoidBottomInset: false, 
      
      // Używamy Stack, aby elementy były niezależne od siebie
      body: SafeArea(
        child: Stack(
          children: [
            // --- 1. LOGO (Pozycja absolutna) ---
            Positioned(
              top: 20,
              left: 20,
              child: SvgPicture.asset(
                'assets/images/Parkcheck.svg',
                width: 164,
                height: 67,
              ),
            ),

            // --- 2. INPUTY (Idealnie wyśrodkowane) ---
            // Center ignoruje inne elementy w Stacku, po prostu bierze środek ekranu
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Ważne: Kolumna zajmuje tylko tyle miejsca ile potrzebują inputy
                  children: [
                    
                    if (_generalError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.red.shade50,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red.shade200)
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.error_outline, color: Colors.red, size: 20),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  _generalError!,
                                  style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    
                    _buildInput(
                      _emailController, "Email", Icons.email, 
                      type: TextInputType.emailAddress,
                      focusNode: _emailFocus,
                      nextFocus: _passwordFocus,
                      errorText: _emailError
                    ),
                    const SizedBox(height: 16),
                    
                    _buildInput(
                      _passwordController, "Hasło", Icons.lock, 
                      isObscure: true,
                      focusNode: _passwordFocus,
                      isLast: true, 
                      onSubmitted: (_) => _login(),
                    ),

                    const SizedBox(height: 20),

                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegistrationScreen()),
                        );
                      },
                      child: RichText(
                        text: const TextSpan(
                          style: TextStyle(color: Colors.grey, fontSize: 14, fontFamily: 'Roboto'),
                          children: [
                            TextSpan(text: "Nie masz konta? "),
                            TextSpan(
                              text: "Zarejestruj się", 
                              style: TextStyle(
                                color: Color(0xFF007AFF),
                                fontWeight: FontWeight.bold, 
                                decoration: TextDecoration.underline
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- 3. PRZYCISK (Przypięty do dołu) ---
            Positioned(
              bottom: 24,
              left: 24,
              right: 24,
              child: SizedBox(
                height: 55,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF007AFF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("ZALOGUJ SIĘ", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInput(
    TextEditingController ctrl, 
    String label, 
    IconData icon, 
    {
      bool isObscure = false, 
      TextInputType? type,
      FocusNode? focusNode,
      FocusNode? nextFocus,
      bool isLast = false,
      Function(String)? onSubmitted,
      String? errorText,
    }) {
    return TextField(
      controller: ctrl,
      obscureText: isObscure,
      keyboardType: type,
      focusNode: focusNode,
      textInputAction: isLast ? TextInputAction.done : TextInputAction.next,
      onSubmitted: onSubmitted ?? (_) {
        if (nextFocus != null) {
          FocusScope.of(context).requestFocus(nextFocus);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey[50],
        errorText: errorText,
      ),
    );
  }
}