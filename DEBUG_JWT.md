# 🔍 Guide de Débogage JWT

## Problème : 401 Unauthorized depuis Flutter

Si vous recevez une erreur `401 Unauthorized` lors de l'accès aux endpoints API depuis Flutter, suivez ces étapes :

## ✅ Vérifications à faire

### 1. Vérifier que le token est bien stocké après login

Dans votre code Flutter, après le login, vérifiez que le token est bien récupéré :

```dart
final response = await http.post(
  Uri.parse('$baseUrl/login'),
  headers: {'Content-Type': 'application/json'},
  body: jsonEncode({
    'phone': phone,
    'password': password,
  }),
);

if (response.statusCode == 200) {
  final data = jsonDecode(response.body);
  print('Token reçu: ${data['token']}'); // Vérifier que le token existe
  // Stocker le token
  token = data['token'];
}
```

### 2. Vérifier que le token est bien envoyé dans les requêtes

Dans votre code Flutter, vérifiez que le header Authorization est bien ajouté :

```dart
Future<Map<String, dynamic>> get(String endpoint) async {
  print('Token utilisé: $token'); // Debug: vérifier le token
  
  final response = await http.get(
    Uri.parse('$baseUrl/$endpoint'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token', // ⚠️ IMPORTANT: Format "Bearer <token>"
    },
  );
  
  print('Status code: ${response.statusCode}'); // Debug
  print('Response: ${response.body}'); // Debug
  
  if (response.statusCode == 401) {
    print('❌ Token invalide ou expiré');
  }
  
  return jsonDecode(response.body);
}
```

### 3. Vérifier les logs Rails

Dans les logs Rails (terminal où tourne `bin/dev`), vous devriez voir :

```
=== AUTH DEBUG ===
Authorization header: "Bearer eyJhbGciOiJIUzI1NiJ9..."
Request headers: {...}
Current client before auth: nil
==================
```

Si le header `Authorization` est `nil`, cela signifie que le token n'est pas envoyé depuis Flutter.

### 4. Format du header Authorization

⚠️ **IMPORTANT** : Le format doit être exactement :
```
Authorization: Bearer <token>
```

**❌ Formats incorrects :**
- `Authorization: <token>` (manque "Bearer ")
- `Authorization: bearer <token>` (minuscule)
- `Authorization: BEARER <token>` (tout en majuscules)

**✅ Format correct :**
- `Authorization: Bearer <token>` (avec un espace après "Bearer")

### 5. Exemple complet Flutter

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl = 'http://VOTRE_IP:3000/api/v1'; // ⚠️ Utilisez l'IP de votre machine, pas localhost
  String? token;

  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'phone': phone,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      token = data['token'];
      print('✅ Login réussi, token: ${token?.substring(0, 20)}...');
      return data;
    } else {
      print('❌ Login échoué: ${response.statusCode} - ${response.body}');
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> getLottoBets({int page = 1, int perPage = 20}) async {
    if (token == null) {
      throw Exception('Token manquant. Veuillez vous connecter.');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/lotto_bets?page=$page&per_page=$perPage'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // ⚠️ Format correct
      },
    );

    print('GET /lotto_bets - Status: ${response.statusCode}');
    
    if (response.statusCode == 401) {
      print('❌ Token invalide ou expiré. Veuillez vous reconnecter.');
      token = null; // Réinitialiser le token
      throw Exception('Token invalide');
    }

    if (response.statusCode != 200) {
      print('❌ Erreur: ${response.body}');
      throw Exception('Erreur API: ${response.statusCode}');
    }

    return jsonDecode(response.body);
  }
}
```

### 6. Tester avec Postman/curl

Pour vérifier que le backend fonctionne, testez d'abord avec Postman ou curl :

```bash
# 1. Login
curl -X POST http://localhost:3000/api/v1/login \
  -H "Content-Type: application/json" \
  -d '{"phone":"+237612345678","password":"password123"}'

# 2. Copier le token de la réponse

# 3. Utiliser le token
curl -X GET http://localhost:3000/api/v1/lotto_bets \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer VOTRE_TOKEN_ICI"
```

### 7. Vérifier l'IP/URL dans Flutter

⚠️ **IMPORTANT pour Flutter** : 
- Ne pas utiliser `localhost` ou `127.0.0.1` depuis un appareil mobile
- Utiliser l'IP locale de votre machine (ex: `192.168.1.100:3000`)
- Pour trouver votre IP : `ip addr show` (Linux) ou `ipconfig` (Windows)

```dart
// ❌ Ne fonctionne pas depuis un appareil mobile
final String baseUrl = 'http://localhost:3000/api/v1';

// ✅ Utilisez l'IP de votre machine
final String baseUrl = 'http://192.168.1.100:3000/api/v1';
```

### 8. Vérifier CORS

Assurez-vous que CORS est bien configuré dans `config/initializers/cors.rb` :

```ruby
Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins '*' # En production, spécifiez les domaines autorisés
    resource '*',
      headers: :any, # ⚠️ Important: permet tous les headers, y compris Authorization
      methods: [:get, :post, :put, :patch, :delete, :options, :head],
      expose: ['Authorization', 'Content-Type'],
      credentials: false
  end
end
```

## 🔧 Solutions courantes

### Problème : Token null après login
**Solution** : Vérifiez que la réponse du login contient bien le champ `token` :
```dart
final data = jsonDecode(response.body);
token = data['token']; // Vérifiez que ce champ existe
```

### Problème : Token expiré
**Solution** : Le token expire après 24h. Implémentez un refresh token ou reconnectez l'utilisateur.

### Problème : Header Authorization non envoyé
**Solution** : Vérifiez que vous ajoutez bien le header dans chaque requête :
```dart
headers: {
  'Authorization': 'Bearer $token',
}
```

### Problème : Format du token incorrect
**Solution** : Le token doit être précédé de "Bearer " (avec un espace) :
```dart
'Authorization': 'Bearer $token' // ✅ Correct
'Authorization': '$token'        // ❌ Incorrect
```

## 📝 Checklist

- [ ] Token stocké après login
- [ ] Header Authorization ajouté à chaque requête
- [ ] Format "Bearer <token>" respecté
- [ ] IP correcte utilisée (pas localhost)
- [ ] CORS configuré correctement
- [ ] Logs Rails vérifiés pour voir le header Authorization
- [ ] Test avec Postman/curl fonctionne

## 🆘 Si le problème persiste

1. Vérifiez les logs Rails pour voir exactement ce qui est reçu
2. Vérifiez les logs Flutter pour voir exactement ce qui est envoyé
3. Testez avec Postman/curl pour isoler le problème
4. Vérifiez que le serveur Rails est bien démarré et accessible

