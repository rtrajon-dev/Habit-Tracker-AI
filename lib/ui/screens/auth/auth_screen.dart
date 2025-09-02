import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:habit/providers/auth_providers.dart';
import 'package:habit/ui/screens/goals_screen.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLogin = true;

  String _email = '';
  String _password = '';
  String _name = '';
  String _gender = '';
  DateTime? _dob;

  bool _loading = false;

  Future<void> _pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _dob = picked);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    if (!_isLogin && _dob == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select your Date of Birth")),
      );
      return;
    }

    setState(() => _loading = true);
    final authService = ref.read(authServiceProvider);

    try {
      if (_isLogin) {
        await authService.login(email: _email, password: _password);
      } else {
        await authService.register(
          email: _email,
          password: _password,
          name: _name,
          gender: _gender,
          dob: _dob!,
        );

        if (mounted) {
          // ✅ Navigate to GoalsScreen after register
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const GoalsScreen()),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDark
                ? [Colors.deepPurple.shade700, Colors.purple.shade900]
                : [Colors.deepPurple, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Card(
              elevation: 12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              color: isDark ? Colors.grey[900] : Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // App Name
                    Text(
                      "Habit Tracker AI",
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        foreground: Paint()
                          ..shader = LinearGradient(
                            colors: isDark
                                ? [Colors.purple.shade200, Colors.deepPurple.shade100]
                                : [Colors.deepPurple, Colors.purpleAccent],
                          ).createShader(Rect.fromLTWH(0, 0, size.width, 0)),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isLogin ? "Welcome Back!" : "Create your account",
                      style: TextStyle(
                        fontSize: 16,
                        color: isDark ? Colors.white70 : Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person),
                                border: OutlineInputBorder(),
                              ),
                              validator: (val) =>
                              val == null || val.isEmpty ? "Enter name" : null,
                              onSaved: (val) => _name = val ?? '',
                            ),
                          if (!_isLogin) const SizedBox(height: 16),

                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (val) {
                              if (val == null || val.isEmpty) return "Enter email";
                              if (!val.contains('@')) return "Enter valid email";
                              return null;
                            },
                            onSaved: (val) => _email = val ?? '',
                          ),
                          const SizedBox(height: 16),

                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock),
                              border: OutlineInputBorder(),
                            ),
                            obscureText: true,
                            validator: (val) {
                              if (val == null || val.isEmpty) return "Enter password";
                              if (val.length < 6) return "Password too short";
                              return null;
                            },
                            onSaved: (val) => _password = val ?? '',
                          ),

                          if (!_isLogin) const SizedBox(height: 16),

                          if (!_isLogin)
                            DropdownButtonFormField<String>(
                              decoration: const InputDecoration(
                                labelText: "Gender",
                                prefixIcon: Icon(Icons.wc),
                                border: OutlineInputBorder(),
                              ),
                              items: const [
                                DropdownMenuItem(value: "Male", child: Text("Male")),
                                DropdownMenuItem(value: "Female", child: Text("Female")),
                                DropdownMenuItem(value: "Other", child: Text("Other")),
                              ],
                              validator: (val) =>
                              val == null || val.isEmpty ? "Select gender" : null,
                              onChanged: (val) => _gender = val ?? '',
                              onSaved: (val) => _gender = val ?? '',
                            ),

                          if (!_isLogin) const SizedBox(height: 16),

                          if (!_isLogin)
                            InkWell(
                              onTap: () => _pickDate(context),
                              child: InputDecorator(
                                decoration: const InputDecoration(
                                  labelText: "Date of Birth",
                                  prefixIcon: Icon(Icons.cake),
                                  border: OutlineInputBorder(),
                                ),
                                child: Text(
                                  _dob == null
                                      ? "Select your date of birth"
                                      : "${_dob!.day}/${_dob!.month}/${_dob!.year}",
                                  style: TextStyle(
                                    color: _dob == null
                                        ? Colors.grey
                                        : (isDark ? Colors.white : Colors.black87),
                                  ),
                                ),
                              ),
                            ),

                          const SizedBox(height: 24),

                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.deepPurple,
                              ),
                              child: _loading
                                  ? const CircularProgressIndicator(
                                  color: Colors.white)
                                  : Text(
                                _isLogin ? "Login" : "Register",
                                style: const TextStyle(
                                    fontSize: 16, color: Colors.white),
                              ),
                            ),
                          ),

                          const SizedBox(height: 12),
                          TextButton(
                            onPressed: () =>
                                setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin
                                  ? "Don't have an account? Register"
                                  : "Already have an account? Login",
                              style: TextStyle(
                                color: isDark
                                    ? Colors.purple.shade200
                                    : Colors.deepPurple,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
