class ApiPath {
  static const assets = '/api/assets';
  static String assetById(String id) => '/api/assets/$id';

  static const intakes = '/api/intakes';
  static String intakeById(String id) => '/api/intakes/$id';

  static const tasks = '/api/tasks';
  static String taskById(String id) => '/api/tasks/$id';

  static const ping = '/health'; // o '/api/ping'
}
