# 🚀 Guide d'Intégration Flutter

Guide pratique pour intégrer l'API Balssa Biyu dans votre application Flutter.

## 📦 Dépendances Flutter

Ajoutez ces dépendances dans votre `pubspec.yaml`:

```yaml
dependencies:
  http: ^1.1.0
  shared_preferences: ^2.2.2
  flutter_secure_storage: ^9.0.0
```

## 🔧 Configuration

### 1. Créer un fichier de configuration

`lib/config/api_config.dart`:

```dart
class ApiConfig {
  // Changez cette URL selon votre environnement
  static const String baseUrl = 'http://localhost:3000/api/v1';
  // Pour Android Emulator: 'http://10.0.2.2:3000/api/v1'
  // Pour iOS Simulator: 'http://localhost:3000/api/v1'
  // Pour device physique: 'http://VOTRE_IP:3000/api/v1'
  
  static const String loginEndpoint = '/login';
  static const String registerEndpoint = '/register';
  static const String logoutEndpoint = '/logout';
  static const String walletEndpoint = '/wallets';
  static const String lottoBetsEndpoint = '/lotto_bets';
  static const String lottoDrawsEndpoint = '/lotto_draws';
  static const String lottoWinsEndpoint = '/lotto_wins';
}
```

## 🔐 Service d'Authentification

`lib/services/auth_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class AuthService {
  static String? _token;
  
  // Récupérer le token depuis le stockage
  static Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }
  
  // Sauvegarder le token
  static Future<void> saveToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }
  
  // Supprimer le token (logout)
  static Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }
  
  // Connexion
  static Future<Map<String, dynamic>> login(String phone, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await saveToken(data['token']);
        return {
          'success': true,
          'data': data['data'],
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? data['message'] ?? 'Erreur de connexion',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }
  
  // Inscription
  static Future<Map<String, dynamic>> register({
    required String phone,
    required String password,
    required String passwordConfirmation,
    String? firstName,
    String? lastName,
    String? email,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'phone': phone,
          'password': password,
          'password_confirmation': passwordConfirmation,
          if (firstName != null) 'first_name': firstName,
          if (lastName != null) 'last_name': lastName,
          if (email != null) 'email': email,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        await saveToken(data['token']);
        return {
          'success': true,
          'data': data['data'],
          'token': data['token'],
        };
      } else {
        return {
          'success': false,
          'error': data['message'] ?? 'Erreur d\'inscription',
          'errors': data['errors'] ?? [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }
  
  // Déconnexion
  static Future<bool> logout() async {
    try {
      final token = await getToken();
      if (token == null) return false;
      
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.logoutEndpoint}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      
      await clearToken();
      return response.statusCode == 200;
    } catch (e) {
      await clearToken();
      return false;
    }
  }
}
```

## 💰 Service Wallet

`lib/services/wallet_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class WalletService {
  // Récupérer les headers avec authentification
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Voir le wallet
  static Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.walletEndpoint}/show'),
        headers: await _getHeaders(),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  // Voir le solde
  static Future<Map<String, dynamic>> getBalance() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.walletEndpoint}/balance'),
        headers: await _getHeaders(),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  // Voir les opérations
  static Future<Map<String, dynamic>> getOperations({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.walletEndpoint}/operations?page=$page&per_page=$perPage'),
        headers: await _getHeaders(),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
```

## 🎫 Service Lotto Bets

`lib/services/lotto_bet_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class LottoBetService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Créer un pari
  static Future<Map<String, dynamic>> createBet({
    required List<int> numbers,
    required String session, // 'morning' ou 'evening'
    required String drawDate, // Format: 'YYYY-MM-DD'
    double amount = 100.0,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoBetsEndpoint}'),
        headers: await _getHeaders(),
        body: jsonEncode({
          'numbers': numbers,
          'session': session,
          'draw_date': drawDate,
          'amount': amount,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 201) {
        return {
          'success': true,
          'data': data['data'],
        };
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Erreur lors de la création du pari',
          'errors': data['errors'] ?? [],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur réseau: ${e.toString()}',
      };
    }
  }
  
  // Consulter les paris
  static Future<Map<String, dynamic>> getBets({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoBetsEndpoint}?page=$page&per_page=$perPage'),
        headers: await _getHeaders(),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  // Voir un pari spécifique
  static Future<Map<String, dynamic>> getBet(int betId) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoBetsEndpoint}/$betId'),
        headers: await _getHeaders(),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
```

## 🎲 Service Lotto Draws

`lib/services/lotto_draw_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

class LottoDrawService {
  // Pas besoin d'authentification pour la plupart des endpoints
  
  // Liste des tirages
  static Future<Map<String, dynamic>> getDraws({
    int page = 1,
    int perPage = 20,
    String? session,
    String? startDate,
    String? endDate,
  }) async {
    try {
      String url = '${ApiConfig.baseUrl}${ApiConfig.lottoDrawsEndpoint}?page=$page&per_page=$perPage';
      if (session != null) url += '&session=$session';
      if (startDate != null) url += '&start_date=$startDate';
      if (endDate != null) url += '&end_date=$endDate';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  // Dernier tirage
  static Future<Map<String, dynamic>> getLatestDraw() async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoDrawsEndpoint}/latest'),
        headers: {'Content-Type': 'application/json'},
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  // Détails d'un tirage
  static Future<Map<String, dynamic>> getDraw(int drawId, {
    bool includeBets = false,
    String? betStatus,
  }) async {
    try {
      String url = '${ApiConfig.baseUrl}${ApiConfig.lottoDrawsEndpoint}/$drawId';
      if (includeBets) {
        url += '?include_bets=true';
        if (betStatus != null) url += '&bet_status=$betStatus';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  // Paris d'un tirage
  static Future<Map<String, dynamic>> getDrawBets(int drawId, {
    String? status,
    int page = 1,
    int perPage = 20,
    String? token, // Optionnel - si fourni, filtre par client
  }) async {
    try {
      String url = '${ApiConfig.baseUrl}${ApiConfig.lottoDrawsEndpoint}/$drawId/bets?page=$page&per_page=$perPage';
      if (status != null) url += '&status=$status';
      
      final headers = <String, String>{
        'Content-Type': 'application/json',
      };
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
      
      final response = await http.get(
        Uri.parse(url),
        headers: headers,
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
```

## 🏆 Service Lotto Wins

`lib/services/lotto_win_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class LottoWinService {
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
  
  // Mes gains
  static Future<Map<String, dynamic>> getWins({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lottoWinsEndpoint}?page=$page&per_page=$perPage'),
        headers: await _getHeaders(),
      );
      
      return jsonDecode(response.body);
    } catch (e) {
      return {'error': e.toString()};
    }
  }
}
```

## 📱 Exemple d'utilisation dans un Widget

```dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/wallet_service.dart';
import '../services/lotto_bet_service.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? walletData;
  bool isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadWallet();
  }
  
  Future<void> _loadWallet() async {
    setState(() => isLoading = true);
    final data = await WalletService.getBalance();
    setState(() {
      walletData = data['data'];
      isLoading = false;
    });
  }
  
  Future<void> _createBet() async {
    final result = await LottoBetService.createBet(
      numbers: [12, 23, 34, 45, 56],
      session: 'evening',
      drawDate: '2025-11-20',
      amount: 150.0,
    );
    
    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Pari créé avec succès!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: ${result['error']}')),
      );
    }
  }
  
  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }
    
    return Scaffold(
      appBar: AppBar(title: Text('Balssa Biyu')),
      body: Column(
        children: [
          if (walletData != null)
            Card(
              child: ListTile(
                title: Text('Solde'),
                subtitle: Text('${walletData!['balance']} FCFA'),
              ),
            ),
          ElevatedButton(
            onPressed: _createBet,
            child: Text('Créer un pari'),
          ),
        ],
      ),
    );
  }
}
```

## 🔧 Configuration pour Android

Si vous testez sur un émulateur Android, utilisez `10.0.2.2` au lieu de `localhost`:

```dart
static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
```

## 🔧 Configuration pour iOS

Pour iOS Simulator, `localhost` fonctionne directement.

## 🔧 Configuration pour Device Physique

Pour un device physique, utilisez l'IP de votre machine:

```dart
static const String baseUrl = 'http://192.168.1.100:3000/api/v1';
```

## ⚠️ Gestion des Erreurs

Créez un helper pour gérer les erreurs:

```dart
class ApiErrorHandler {
  static String getErrorMessage(Map<String, dynamic> response) {
    if (response.containsKey('error')) {
      return response['error'];
    }
    if (response.containsKey('errors') && response['errors'] is List) {
      return response['errors'].join(', ');
    }
    if (response.containsKey('message')) {
      return response['message'];
    }
    return 'Une erreur est survenue';
  }
}
```

## 🔐 Sécurité

Pour la production, utilisez `flutter_secure_storage` pour stocker le token:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureTokenStorage {
  static final _storage = FlutterSecureStorage();
  
  static Future<void> saveToken(String token) async {
    await _storage.write(key: 'auth_token', value: token);
  }
  
  static Future<String?> getToken() async {
    return await _storage.read(key: 'auth_token');
  }
  
  static Future<void> clearToken() async {
    await _storage.delete(key: 'auth_token');
  }
}
```

---

**Note:** N'oubliez pas de redémarrer votre serveur Rails après avoir configuré CORS!

