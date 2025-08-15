class AppConfig {
  static final AppConfig _instance = AppConfig._internal();
  factory AppConfig() => _instance;
  AppConfig._internal();

  // Base url
  // String get baseUrl => 'http://173.249.35.253:3000'; // Original server (currently down)
  
  // Alternative URLs for testing (uncomment if main server is down)
  String get baseUrl => 'https://jsonplaceholder.typicode.com'; // For testing
  // String get baseUrl => 'http://localhost:3000'; // For local testing

  // Auth endpoints
  String get loginEndpoint => '$baseUrl/auth/login';
  String get registerEndpoint => '$baseUrl/auth/register';

  //dummy json
  String get todoEndpoint => 'http://dummyjson.com/todos';

  // Course endpoints
  String get getAllCoursesEndpoint => '$baseUrl/course';
  String getCourseDetails(int id) => '$baseUrl/course/$id';

  String get getAllTakenEndpoint => '$baseUrl/categoery';

  // Author
  String get getAllAuthorsEndpoint => '$baseUrl/author';
  String getAuthorCoursesEndpoint(String id) => '$baseUrl/author/$id/courses';
  String getAuthorById(String id) => '$baseUrl/author/$id';

  // Skill
  String get getAllSkillsEndpoint => '$baseUrl/skill';

  // Category
  String get getAllCategoriesEndpoint => '$baseUrl/category';

  Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  Duration get connectionTimeout => const Duration(seconds: 30);
  Duration get receiveTimeout => const Duration(seconds: 30);
}
