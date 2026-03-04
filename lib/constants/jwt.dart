import 'package:jwt_decode/jwt_decode.dart';


String? getUserIdFromToken(String token) {
  try {
    print('🔍 Parsing JWT token for userId...');
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    
    // ✅ Print ALL keys for debugging
    print('📋 All JWT payload keys: ${payload.keys.toList()}');
    
    // ✅ Try ALL possible key combinations
    String? userId;
    
    // Common JWT structures
    userId = payload['id']?.toString();
    if (userId != null) {
      print('✅ Found userId in "id": $userId');
      return userId;
    }
    
    userId = payload['userId']?.toString();
    if (userId != null) {
      print('✅ Found userId in "userId": $userId');
      return userId;
    }
    
    userId = payload['user_id']?.toString();
    if (userId != null) {
      print('✅ Found userId in "user_id": $userId');
      return userId;
    }
    
    userId = payload['_id']?.toString();
    if (userId != null) {
      print('✅ Found userId in "_id": $userId');
      return userId;
    }
    
    userId = payload['sub']?.toString();  // JWT standard subject field
    if (userId != null) {
      print('✅ Found userId in "sub": $userId');
      return userId;
    }
    
    userId = payload['uid']?.toString();
    if (userId != null) {
      print('✅ Found userId in "uid": $userId');
      return userId;
    }
    
    // If none of the above, check nested structures
    if (payload['user'] != null && payload['user'] is Map) {
      final userMap = payload['user'] as Map;
      userId = userMap['id']?.toString() ?? 
               userMap['userId']?.toString() ?? 
               userMap['_id']?.toString();
      if (userId != null) {
        print('✅ Found userId in nested "user" object: $userId');
        return userId;
      }
    }
    
    if (payload['data'] != null && payload['data'] is Map) {
      final dataMap = payload['data'] as Map;
      userId = dataMap['id']?.toString() ?? 
               dataMap['userId']?.toString() ?? 
               dataMap['_id']?.toString();
      if (userId != null) {
        print('✅ Found userId in nested "data" object: $userId');
        return userId;
      }
    }
    
    // Last resort: Print entire payload to see structure
    print('❌ No standard userId field found');
    print('📄 Full JWT payload:');
    payload.forEach((key, value) {
      print('   $key: $value (${value.runtimeType})');
    });
    
    return null;
    
  } catch (e) {
    print('❌ JWT parse error: $e');
    return null;
  }
}