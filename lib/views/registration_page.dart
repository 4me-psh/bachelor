import 'dart:io';
import 'package:bachelor/utils/jwt_storage.dart';
import 'package:bachelor/views/home_page.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/auth_controller.dart';
import '../controllers/person_controller.dart';
import '../models/person.dart';

class RegistrationPage extends StatefulWidget {
  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final _authController = AuthController();
  final _personController = PersonController();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();

  final _hairColorController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  Gender _selectedGender = Gender.male;
  SkinTone _selectedTone = SkinTone.medium;

  File? _selectedImage;
  bool _loading = false;

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final pass = _passController.text.trim();

    final success = await _authController.register(name, email, pass);
    if (!success) {
      setState(() => _loading = false);
      _showError('Не вдалося створити акаунт');
      return;
    }

    final userId = await JwtStorage.getUserId();
    final person = Person(
      userId: userId,
      gender: _selectedGender,
      skinTone: _selectedTone,
      hairColor: _hairColorController.text.trim(),
      height: double.tryParse(_heightController.text) ?? 170,
      age: int.tryParse(_ageController.text) ?? 25,
      pathToPerson: '',
    );

    try {
      if (_selectedImage != null) {
        await _personController.createPersonWithPhoto(person, _selectedImage!);
      } else {
        await _personController.createPerson(person);
      }

      final userId = await JwtStorage.getUserId();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(userId: userId!, selectedPage: 0),
        ),
      );
    } catch (e) {
      _showError('Помилка при додавання персональних даних: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Реєстрація'),
          centerTitle: true,),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child:
              _loading
                  ? const Center(child: CircularProgressIndicator())
                  : Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        Center(
                          child: const Text(
                            'Акаунт',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nameController,
                          decoration: const InputDecoration(labelText: 'Імʼя'),
                          validator:
                              (val) => val!.isEmpty ? 'Обовʼязково' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          decoration: const InputDecoration(labelText: 'Email'),
                          validator:
                              (val) =>
                                  val!.contains('@')
                                      ? null
                                      : 'Некоректний email',
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _passController,
                          decoration: const InputDecoration(
                            labelText: 'Пароль',
                          ),
                          obscureText: true,
                          validator:
                              (val) =>
                                  val!.length < 6 ? 'Мінімум 6 символів' : null,
                        ),
                        const SizedBox(height: 20),
                        Center(
                          child: const Text(
                            'Персональні дані',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<Gender>(
                          value: _selectedGender,
                          decoration: const InputDecoration(labelText: 'Стать'),
                          items:
                              Gender.values
                                  .map(
                                    (g) => DropdownMenuItem(
                                      value: g,
                                      child: Text(g.nameUa),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedGender = val!),
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<SkinTone>(
                          value: _selectedTone,
                          decoration: const InputDecoration(
                            labelText: 'Колір шкіри',
                          ),
                          items:
                              SkinTone.values
                                  .map(
                                    (s) => DropdownMenuItem(
                                      value: s,
                                      child: Text(s.nameUa),
                                    ),
                                  )
                                  .toList(),
                          onChanged:
                              (val) => setState(() => _selectedTone = val!),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _hairColorController,
                          decoration: const InputDecoration(
                            labelText: 'Колір волосся',
                          ),
                          validator:
                              (val) => val!.isEmpty ? 'Обовʼязково' : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                            labelText: 'Зріст (см)',
                          ),
                          keyboardType: TextInputType.number,
                          validator:
                              (val) =>
                                  double.tryParse(val!) == null
                                      ? 'Введіть число'
                                      : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(labelText: 'Вік'),
                          keyboardType: TextInputType.number,
                          validator:
                              (val) =>
                                  int.tryParse(val!) == null
                                      ? 'Введіть число'
                                      : null,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickImage,
                              icon: const Icon(Icons.photo),
                              label: const Text('Вибрати фото'),
                            ),
                            const SizedBox(width: 12),
                            if (_selectedImage != null)
                              const Text('Фото вибрано'),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _submit,
                          child: const Text('Зареєструватися'),
                        ),
                      ],
                    ),
                  ),
        ),
      ),
    );
  }
}
