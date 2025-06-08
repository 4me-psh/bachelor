import 'package:flutter/material.dart';
import '../controllers/auth_controller.dart';
import '../widgets/custom_text_field.dart';
import '../utils/jwt_storage.dart';
import 'home_page.dart';
import 'registration_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final AuthController _auth = AuthController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _loading = false;
  String? _error;

  Future<void> _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    final success = await _auth.login(
      _emailController.text,
      _passwordController.text,
    );

    setState(() => _loading = false);

    if (success) {
      final userId = await JwtStorage.getUserId();
      if (!mounted || userId == null) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomePage(userId: userId)),
      );
    } else {
      setState(() {
        _error = 'Невірний email або пароль';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Scaffold(
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Вхід', style: Theme.of(context).textTheme.headlineLarge),
                const SizedBox(height: 16),
                CustomTextField(
                  controller: _emailController,
                  labelText: 'Email',
                ),
                CustomTextField(
                  controller: _passwordController,
                  labelText: 'Пароль',
                  obscureText: true,
                ),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _login,
                  child: _loading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Увійти'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => RegistrationPage()),
                    );
                  },
                  child: const Text('Не маєте акаунту? Зареєструйтесь'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
