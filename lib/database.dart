import 'dart:convert' as convert;
import 'package:http/http.dart' as http;

const String baseURL = '12230899.atwebpages.com';


class Employee {
  final int id;
  final String employeeId;
  final String fullName;

  Employee({required this.id, required this.employeeId, required this.fullName});
}

class LocationItem {
  final int id;
  final String name;

  LocationItem({required this.id, required this.name});
}

class PunchItem {
  final int id;
  final String location;
  final String punchType;
  final String punchTime;

  PunchItem({
    required this.id,
    required this.location,
    required this.punchType,
    required this.punchTime,
  });
}

Employee? currentEmployee;
List<LocationItem> locations = [];
List<PunchItem> punches = [];


Future<void> login(String employeeId, String password, Function(bool ok, String msg) done) async {
  try {
    final url = Uri.http(baseURL, 'login.php');
    final res = await http.post(url, body: {
      'employee_id': employeeId,
      'password': password,
    }).timeout(const Duration(seconds: 5));

    final json = convert.jsonDecode(res.body);
    if (json['success'] == true) {
      final e = json['employee'];
      currentEmployee = Employee(
        id: int.parse(e['id'].toString()),
        employeeId: e['employee_id'].toString(),
        fullName: e['full_name'].toString(),
      );
      done(true, 'ok');
    } else {
      done(false, (json['error'] ?? 'Login failed').toString());
    }
  } catch (e) {
    done(false, 'Network error');
  }
}


Future<void> getLocations(Function(bool ok) loaded) async {
  try {
    final url = Uri.http(baseURL, 'get_locations.php');
    final res = await http.get(url).timeout(const Duration(seconds: 5));

    locations.clear();
    if (res.statusCode == 200) {
      final arr = convert.jsonDecode(res.body);
      for (var row in arr) {
        locations.add(LocationItem(
          id: int.parse(row['id'].toString()),
          name: row['name'].toString(),
        ));
      }
      loaded(true);
      return;
    }
    loaded(false);
  } catch (_) {
    loaded(false);
  }
}

Future<void> punch(int locationId, String type, Function(bool ok) done) async {
  try {
    if (currentEmployee == null) {
      done(false);
      return;
    }
    final url = Uri.http(baseURL, 'punch.php');
    final res = await http.post(url, body: {
      'employee_db_id': currentEmployee!.id.toString(),
      'location_id': locationId.toString(),
      'punch_type': type,
    }).timeout(const Duration(seconds: 5));

    final json = convert.jsonDecode(res.body);
    done(json['success'] == true);
  } catch (_) {
    done(false);
  }
}


Future<void> getPunches(Function(bool ok) loaded) async {
  try {
    if (currentEmployee == null) {
      loaded(false);
      return;
    }

    final url = Uri.http(baseURL, 'get_punches.php', {
      'employee_db_id': currentEmployee!.id.toString(),
    });

    final res = await http.get(url).timeout(const Duration(seconds: 5));

    punches.clear();
    if (res.statusCode == 200) {
      final arr = convert.jsonDecode(res.body);
      for (var row in arr) {
        punches.add(PunchItem(
          id: int.parse(row['id'].toString()),
          location: row['location'].toString(),
          punchType: row['punch_type'].toString(),
          punchTime: row['punch_time'].toString(),
        ));
      }
      loaded(true);
      return;
    }
    loaded(false);
  } catch (_) {
    loaded(false);
  }
}
