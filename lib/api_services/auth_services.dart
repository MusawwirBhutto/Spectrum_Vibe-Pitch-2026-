import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:baalkatwao/models/SalonModel.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';

final String baseUrl = 'https://apiaceous-unenviably-maxima.ngrok-free.app';

//----------------------------------------------SIGN UP USER MEHOD----------------------------------------------
Future<void> signupUser({
  required String username,
  required String email,
  required String password,
  required String phone,
  required String signupAs,
}) async {
  final url = Uri.parse('$baseUrl/auth/signup');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'username': username,
      'email': email,
      'password': password,
      'phone': phone,
      'signup_as': signupAs,
    }),
  );

  if (response.statusCode == 200 || response.statusCode == 201) {
    return;
  } else {
    try {
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ?? 'Signup failed with an unknown error.',
      );
    } catch (e) {
      throw Exception('Failed to sign up: ${response.body}');
    }
  }
}

//----------------------------------------------VERIFY EMAIL MEHOD----------------------------------------------
Future<void> verifyEmail({
  required String email,
  required String code,
  required String verificationType,
}) async {
  final encodedverificationType = Uri.encodeQueryComponent(verificationType);

  final url = Uri.parse(
    '$baseUrl/auth/verify?verificationType=$encodedverificationType',
  );
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': email, 'code': code}),
  );

  if (response.statusCode != 200) {
    throw Exception('Failed to verify email: ${response.body}');
  }
}

//----------------------------------------------LOGIN USER MEHOD----------------------------------------------
Future<Map<String, dynamic>> loginUser({
  required String email,
  required String password,
}) async {
  final url = Uri.parse('$baseUrl/auth/login');
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': email, 'password': password}),
  );

  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data; // the data here is the token that will be returned
  } else {
    throw Exception('Login failed: ${response.body}');
  }
}

//----------------------------------------------GET LOGGED IN USER MEHOD----------------------------------------------
Future<Map<String, dynamic>> getLoggedInUser(String token) async {
  final url = Uri.parse('$baseUrl/auth/loggedInUser');

  try {
    final response = await http
        .get(
          url,
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode == 200) {
      try {
        return json.decode(response.body);
      } on FormatException catch (e) {
        throw Exception('Failed to decode user data: $e');
      }
    } else {
      final errorMessage =
          'Failed to fetch user data. Status: ${response.statusCode}. Body: ${response.body}';
      throw Exception(errorMessage);
    }
  } on TimeoutException {
    throw Exception(
      'API request timed out. Check your server status or internet connection.',
    );
  } catch (e) {
    throw Exception('Network error during user data fetch: $e');
  }
}

//----------------------------------------------SEND VERIFICATION CODE MEHOD----------------------------------------------
Future<void> sendVerificationCode({
  required String email,
  required verificationType,
}) async {
  final encodedemail = Uri.encodeQueryComponent(email);
  final encodedverificationType = Uri.encodeQueryComponent(verificationType);

  final url = Uri.parse(
    '$baseUrl/auth/sendVerificationCode?email=$encodedemail&verificationType=$encodedverificationType',
  );

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode != 200) {
    final errorMessage =
        'Failed to resend code: ${response.statusCode} - ${response.body}';
    throw Exception(errorMessage);
  }
}

//----------------------------------------------UPLOAD PROFILE IMAGE MEHOD----------------------------------------------

Future<Map<String, dynamic>> uploadProfileImage({
  required String? token,
  required XFile imageFile,
}) async {
  final String imagePath = imageFile.path;

  if (token == null || token.isEmpty) {
    throw Exception('Authentication token is missing. Cannot upload image.');
  }
  if (imagePath.isEmpty) {
    throw Exception('Image file path is unavailable or empty. Cannot upload.');
  }

  final url = Uri.parse('$baseUrl/uploadProfileImage');
  var request = http.MultipartRequest('PATCH', url);

  request.headers.addAll({'Authorization': 'Bearer $token'});

  final file = File(imagePath);
  if (!await file.exists()) {
    throw Exception('Image file not found on disk at the specified path.');
  }

  final String filename = imagePath.split('/').last;

  request.files.add(
    await http.MultipartFile.fromPath(
      'profileImage',
      imageFile.path,
      filename: filename,
    ),
  );

  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
    final data = json.decode(response.body);

    if (data['imageUrl'] == null) {
      throw Exception(
        'Upload succeeded but no imageUrl returned: ${response.body}',
      );
    }

    return data;
  } else {
    throw Exception(
      'Failed to upload profile picture. Status: ${response.statusCode}. Body: ${response.body}',
    );
  }
}

//----------------------------------------------UPDATE USER PROFILE MEHOD----------------------------------------------
Future<Map<String, dynamic>> updateUserProfile({
  required String token,
  required Map<String, dynamic> updatedData,
}) async {
  final url = Uri.parse('$baseUrl/user/profile');

  final response = await http.patch(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode(updatedData),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data;
  } else {
    try {
      final errorData = json.decode(response.body);
      throw Exception(
        errorData['message'] ??
            'Profile update failed with status ${response.statusCode}',
      );
    } catch (e) {
      throw Exception(
        'Failed to update profile: Status ${response.statusCode}. Body: ${response.body}',
      );
    }
  }
}

//--------------------------------------------------change password method----------------------------------------------
Future<void> changePassword({
  required String token,
  required String currentpassword,
  required String newpassword,
  required String confirmpassword,
}) async {
  final url = Uri.parse('$baseUrl/auth/changePassword');

  final response = await http.post(
    url,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode({
      'oldPassword': currentpassword,
      'newPassword': newpassword,
      'confirmPassword': confirmpassword,
    }),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    String errorMessage =
        'Failed to change password: Status ${response.statusCode}.';
    try {
      final errorData = json.decode(response.body);

      errorMessage = errorData['message'] ?? errorMessage;
    } catch (_) {
      errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
    }

    throw Exception(errorMessage);
  }
}
//-------------------------verify Email for Changing email----------------------------------------------------------------------------

Future<Map<String, dynamic>> verifyEmailforChangingEmail({
  required String email,
  required String verificationType,
  required String code,
}) async {
  final encodedverificationType = Uri.encodeQueryComponent(verificationType);
  final url = Uri.parse(
    '$baseUrl/auth/verify?verificationType=$encodedverificationType',
  );
  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({'email': email, 'code': code}),
  );
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return data;
  } else {
    throw Exception('Failed to verify email: ${response.body}');
  }
}

//------------------------------------------------reset password method----------------------------------------------
Future<void> resetPassword({
  required String confirmPassword,
  required String newPassword,
  required String email,
}) async {
  final url = Uri.parse('$baseUrl/auth/forgetPassword');

  final response = await http.post(
    url,
    headers: {'Content-Type': 'application/json'},
    body: json.encode({
      'newPassword': newPassword,
      'confirmPassword': confirmPassword,
      'email': email,
    }),
  );

  if (response.statusCode == 200) {
    return;
  } else {
    String errorMessage =
        'Failed to reset password: Status ${response.statusCode}.';
    try {
      final errorData = json.decode(response.body);
      errorMessage = errorData['message'] ?? errorMessage;
    } catch (_) {
      errorMessage = response.body.isNotEmpty ? response.body : errorMessage;
    }
    throw Exception(errorMessage);
  }
}

//---------------------------------Create Business Profile-----------------------------------------------

// In your auth_services.dart file

// In your auth_services.dart file

Future<void> createBusinessProfile({
  required String token,
  required Map<String, dynamic> businessProfile,
  required List<Map<String, dynamic>> services,
  required List<Map<String, dynamic>> businessHours,
  required List<File> images,
}) async {
  final url = Uri.parse('$baseUrl/business/profile');
  var request = http.MultipartRequest('PATCH', url);

  request.headers.addAll({
    'Authorization': 'Bearer $token',
    'ngrok-skip-browser-warning': 'true',
  });

  // --- THIS IS THE KEY CHANGE ---
  // Instead of using request.fields, we add the JSON parts as files
  // with the correct 'application/json' content type.

  // Part 1: businessProfile
  request.files.add(
    http.MultipartFile.fromString(
      'businessProfile', // The field name
      json.encode(businessProfile), // The data
      contentType: MediaType('application', 'json'), // The crucial content type
    ),
  );

  // Part 2: services
  request.files.add(
    http.MultipartFile.fromString(
      'services',
      json.encode(services),
      contentType: MediaType('application', 'json'),
    ),
  );

  // Part 3: businessHours
  request.files.add(
    http.MultipartFile.fromString(
      'businessHours',
      json.encode(businessHours),
      contentType: MediaType('application', 'json'),
    ),
  );

  // The image part stays the same
  for (var imageFile in images) {
    request.files.add(
      await http.MultipartFile.fromPath('images', imageFile.path),
    );
  }

  // The rest of the function is unchanged
  final streamedResponse = await request.send();
  final response = await http.Response.fromStream(streamedResponse);

  if (response.statusCode == 200) {
  } else {
    throw Exception(
      'Failed to update profile. Status: ${response.statusCode}. Body: ${response.body}',
    );
  }
}
//--------------------------------------------get salons data method----------------------------------------------------

Future<List<Salon>> getSalonsData({
  required int pageNumber,
  required int pageSize,
}) async {
  final url = Uri.parse(
    "$baseUrl/business?pageNumber=$pageNumber&pageSize=$pageSize",
  );

  final response = await http.get(
    url,
    headers: {'Content-Type': 'application/json'},
  );

  if (response.statusCode == 200) {
    List<dynamic> body = json.decode(response.body);

    List<Salon> salons = body
        .map((dynamic item) => Salon.fromJson(item))
        .toList();
    return salons;
  } else {
    throw Exception('Failed to load salons: ${response.body}');
  }
}
