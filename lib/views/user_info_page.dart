import 'dart:io';
import 'package:bachelor/controllers/person_controller.dart';
import 'package:bachelor/controllers/user_controller.dart';
import 'package:bachelor/models/person.dart';
import 'package:bachelor/models/user.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserInfoPage extends StatefulWidget {
  final int userId;
  const UserInfoPage({Key? key, required this.userId}) : super(key: key);

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends State<UserInfoPage> {
  User? _user;
  Person? _person;
  bool _isLoading = true;
  bool _isEditing = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _hairColorController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  final _userController = UserController();
  final _personController = PersonController();

  String? _selectedGender;
  String? _selectedSkinTone;

  File? _newPhotoFile;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    _user = await _userController.getCurrentUser();
    _person = await _personController.getPersonByUserId(widget.userId);
    if (_user != null && _person != null) {
      _nameController.text = _user!.name!;
      _emailController.text = _user!.email;
      _hairColorController.text = _person!.hairColor;
      _heightController.text = _person!.height.toString();
      _ageController.text = _person!.age.toString();
      _selectedGender = _genderToUa(_person!.gender);
      _selectedSkinTone = _skinToneToUa(_person!.skinTone);
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _hairColorController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _newPhotoFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _saveChanges() async {
    if (_user == null || _person == null) return;

    final updatedUser = User(
      id: _user!.id,
      email: _user!.email,
      name: _nameController.text,
      password: _user!.password,
    );

    final updatedPerson = Person(
      id: _person!.id,
      userId: _person!.userId,
      gender: _genderFromUa(_selectedGender!),
      skinTone: _skinToneFromUa(_selectedSkinTone!),
      hairColor: _hairColorController.text,
      height: double.tryParse(_heightController.text) ?? _person!.height,
      age: int.tryParse(_ageController.text) ?? _person!.age,
      pathToPerson: _person!.pathToPerson,
    );

    try {
      if (_newPhotoFile != null) {
        await _personController.updatePersonWithPhoto(
          updatedPerson,
          _newPhotoFile!,
        );
      } else {
        await _personController.updatePerson(updatedPerson);
      }

      await _userController.updateUser(updatedUser);

      setState(() {
        _isEditing = false;
        _newPhotoFile = null;
        _loadData();
      });
    } catch (e) {
      print('Не вдалось оновити: $e');
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Помилка оновлення: $e")));
    }
  }

  Gender _genderFromUa(String val) {
    return Gender.values.firstWhere(
      (g) => g.nameUa == val,
      orElse: () => Gender.male,
    );
  }

  SkinTone _skinToneFromUa(String val) {
    return SkinTone.values.firstWhere(
      (s) => s.nameUa == val,
      orElse: () => SkinTone.medium,
    );
  }

  String _genderToUa(Gender g) => g.nameUa;
  String _skinToneToUa(SkinTone t) => t.nameUa;

  String _skinToneWithEmoji(String nameUa) {
    switch (nameUa) {
      case 'Світлий':
        return '👍🏻 $nameUa';
      case 'Середньо-світлий':
        return '👍🏼  $nameUa';
      case 'Середній':
        return '👍🏽  $nameUa';
      case 'Середньо-темний':
        return '👍🏾  $nameUa';
      case 'Темний':
        return '👍🏿 $nameUa';
      default:
        return nameUa;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Інформація користувача'),
        automaticallyImplyLeading: false,
        leading:
            _isEditing
                ? IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _newPhotoFile = null;
                    });
                  },
                )
                : null,
        actions: [
          if (!_isLoading)
            _isEditing
                ? IconButton(icon: Icon(Icons.check), onPressed: _saveChanges)
                : IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
        ],
      ),
      body:
          _isLoading
              ? Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundImage:
                                _newPhotoFile != null
                                    ? FileImage(_newPhotoFile!)
                                    : (_person!.pathToPerson!.isNotEmpty
                                        ? NetworkImage(_person!.getImage())
                                        : AssetImage(
                                              'assets/default_avatar.jpg',
                                            )
                                            as ImageProvider),
                          ),
                          if (_isEditing)
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: InkWell(
                                onTap: _pickImage,
                                child: CircleAvatar(
                                  radius: 18,
                                  backgroundColor: Colors.blue,
                                  child: Icon(
                                    Icons.camera_alt,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: _nameController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: "Ім'я",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      enabled: false,
                      decoration: InputDecoration(
                        labelText: "Email",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Стать",
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedGender,
                      items:
                          Gender.values
                              .map(
                                (g) => DropdownMenuItem(
                                  value: g.nameUa,
                                  child: Text(g.nameUa),
                                ),
                              )
                              .toList(),
                      onChanged:
                          _isEditing
                              ? (newGender) {
                                setState(() {
                                  _selectedGender = newGender;
                                });
                              }
                              : null,
                    ),
                    SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: "Відтінок шкіри",
                        border: OutlineInputBorder(),
                      ),
                      value: _selectedSkinTone,
                      items:
                          SkinTone.values
                              .map(
                                (t) => DropdownMenuItem(
                                  value: t.nameUa,
                                  child: Text(_skinToneWithEmoji(t.nameUa)),
                                ),
                              )
                              .toList(),
                      onChanged:
                          _isEditing
                              ? (newTone) {
                                setState(() {
                                  _selectedSkinTone = newTone;
                                });
                              }
                              : null,
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _hairColorController,
                      enabled: _isEditing,
                      decoration: InputDecoration(
                        labelText: "Колір волосся",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _heightController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Зріст (см)",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 8),
                    TextField(
                      controller: _ageController,
                      enabled: _isEditing,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: "Вік",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }
}
