import 'dart:io';
import '../connections/person_api.dart';
import '../models/person.dart';

class PersonController {
  final PersonApi _api = PersonApi();

  Future<Person> getPersonById(int id) async {
    return await _api.getPersonById(id);
  }

  Future<Person> createPerson(Person person) async {
    final created = await _api.createPerson(person);
    return created;
  }

  Future<Person> createPersonWithPhoto(Person person, File imageFile) async {
    final created = await _api.createPersonWithPhoto(person, imageFile);
    return created;
  }

  Future<void> updatePerson(Person person) async {
    await _api.updatePerson(person);
  }

  Future<void> updatePersonWithPhoto(Person person, File imageFile) async {
    await _api.updatePersonWithPhoto(person, imageFile);
  }

  Future<void> deletePerson(int id) async {
    await _api.deletePerson(id);
  }

Future<Person> getPersonByUserId(int id) async {
    return await _api.getPersonByUserId(id);
  }
}
