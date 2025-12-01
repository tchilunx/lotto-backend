# 📱 API Documentation - Balssa Biyu

Documentation complète des endpoints API pour l'application Flutter.

**Base URL:** `http://localhost:3000/api/v1` (développement)  
**Content-Type:** `application/json`  
**Authentication:** JWT Token dans le header `Authorization: Bearer <token>`

---

## 🔐 Authentification

### 1. Inscription (Register)

**POST** `/api/v1/register`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "phone": "+237612345678",
  "password": "password123",
  "password_confirmation": "password123",
  "first_name": "John",
  "last_name": "Doe",
  "email": "john@example.com" // Optionnel
}
```

**Réponse Succès (200):**
```json
{
  "message": "Signed up successfully.",
  "data": {
    "id": 1,
    "phone": "+237612345678",
    "first_name": "John",
    "last_name": "Doe",
    "email": "john@example.com",
    "kyc_valid": false
  },
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Réponse Erreur (422):**
```json
{
  "message": "Sign up failed",
  "errors": ["Phone has already been taken", "Password is too short"]
}
```

---

### 2. Connexion (Login)

**POST** `/api/v1/login`

**Headers:**
```
Content-Type: application/json
```

**Body:**
```json
{
  "phone": "+237612345678",
  "password": "password123"
}
```

**Réponse Succès (200):**
```json
{
  "message": "Connexion réussie.",
  "data": {
    "id": 1,
    "phone": "+237612345678",
    "first_name": "John",
    "last_name": "Doe"
  },
  "token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Réponse Erreur (401):**
```json
{
  "error": "Unauthorized",
  "message": "Invalid phone or password."
}
```

---

### 3. Déconnexion (Logout)

**DELETE** `/api/v1/logout`

**Headers:**
```
Authorization: Bearer <token>
```

**Réponse Succès (200):**
```json
{
  "message": "Logged out successfully"
}
```

---

## 💰 Wallet (Portefeuille)

### 4. Voir le wallet

**GET** `/api/v1/wallets/show`

**Headers:**
```
Authorization: Bearer <token>
```

**Réponse (200):**
```json
{
  "data": {
    "id": 1,
    "client_id": 1,
    "wallet_type": "primary_wallet",
    "real_balance": "1000.0",
    "theoretical_balance": "250.0",
    "locked": false
  }
}
```

---

### 5. Voir le solde

**GET** `/api/v1/wallets/balance`

**Headers:**
```
Authorization: Bearer <token>
```

**Réponse (200):**
```json
{
  "data": {
    "balance": "1000.0",
    "real_balance": "1000.0",
    "theoretical_balance": "250.0",
    "currency": "FCFA"
  }
}
```

---

### 6. Voir les opérations

**GET** `/api/v1/wallets/operations?page=1&per_page=20`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `page` (optionnel): Numéro de page (défaut: 1)
- `per_page` (optionnel): Éléments par page (défaut: 20, max: 100)

**Réponse (200):**
```json
{
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_count": 100,
    "next_page": 2,
    "prev_page": null
  },
  "data": [
    {
      "id": 1,
      "operation_type": "credit",
      "amount": "100.0",
      "balance_before": "900.0",
      "balance_after": "1000.0",
      "reference": "TOPUP-ABC123",
      "status": "completed",
      "created_at": "2025-11-20T10:00:00.000Z"
    }
  ]
}
```

---

## 🎫 Lotto - Paris

### 7. Créer un pari

**POST** `/api/v1/lotto_bets`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "numbers": [12, 23, 34, 45, 56],
  "session": "evening",
  "draw_date": "2025-11-20",
  "amount": 150.0
}
```

**Paramètres:**
- `numbers` (array, requis): 5 numéros uniques entre 1 et 90
- `session` (string, requis): `"morning"` ou `"evening"`
- `draw_date` (date, requis): Date du tirage (format: YYYY-MM-DD)
- `amount` (decimal, optionnel): Montant du pari (défaut: 100.0)

**Réponse Succès (201):**
```json
{
  "message": "Pari créé avec succès",
  "data": {
    "id": 1,
    "numbers": [12, 23, 34, 45, 56],
    "session": "evening",
    "draw_date": "2025-11-20",
    "amount": "150.0",
    "status": "pending",
    "bet_reference": "BET-ABC123",
    "lotto_draw_id": null
  }
}
```

**Réponse Erreur (422):**
```json
{
  "error": "Les paris sont fermés pour ce tirage (fermeture 5 minutes avant le tirage à 20:20)"
}
```

---

### 8. Consulter les paris

**GET** `/api/v1/lotto_bets?page=1&per_page=20`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `page` (optionnel): Numéro de page
- `per_page` (optionnel): Éléments par page

**Réponse (200):**
```json
{
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 5,
    "next_page": null,
    "prev_page": null
  },
  "data": [
    {
      "id": 1,
      "numbers": [12, 23, 34, 45, 56],
      "session": "evening",
      "draw_date": "2025-11-20",
      "amount": "150.0",
      "status": "won",
      "bet_reference": "BET-ABC123"
    }
  ]
}
```

---

### 9. Voir un pari spécifique

**GET** `/api/v1/lotto_bets/:id`

**Headers:**
```
Authorization: Bearer <token>
```

**Réponse (200):**
```json
{
  "data": {
    "id": 1,
    "numbers": [12, 23, 34, 45, 56],
    "session": "evening",
    "draw_date": "2025-11-20",
    "amount": "150.0",
    "status": "won",
    "bet_reference": "BET-ABC123",
    "lotto_draw_id": 1
  }
}
```

---

## 🎲 Lotto - Tirages

### 10. Liste des tirages

**GET** `/api/v1/lotto_draws?page=1&per_page=20&session=evening&start_date=2025-11-20&end_date=2025-11-21`

**Headers:**
```
Content-Type: application/json
```
(Authentification non requise)

**Query Parameters:**
- `page` (optionnel): Numéro de page
- `per_page` (optionnel): Éléments par page
- `session` (optionnel): Filtrer par session (`"morning"` ou `"evening"`)
- `start_date` (optionnel): Date de début (format: YYYY-MM-DD)
- `end_date` (optionnel): Date de fin (format: YYYY-MM-DD)

**Réponse (200):**
```json
{
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 10,
    "next_page": null,
    "prev_page": null
  },
  "data": [
    {
      "id": 1,
      "session": "evening",
      "draw_date": "2025-11-20",
      "numbers": [12, 34, 45, 67, 89],
      "status": "completed",
      "drawn_at": "2025-11-20T20:20:00.000Z"
    }
  ]
}
```

---

### 11. Dernier tirage

**GET** `/api/v1/lotto_draws/latest`

**Headers:**
```
Content-Type: application/json
```
(Authentification non requise)

**Réponse (200):**
```json
{
  "data": {
    "id": 1,
    "session": "evening",
    "draw_date": "2025-11-20",
    "numbers": [12, 34, 45, 67, 89],
    "status": "completed"
  }
}
```

---

### 12. Détails d'un tirage

**GET** `/api/v1/lotto_draws/:id?include_bets=true`

**Headers:**
```
Content-Type: application/json
```
(Authentification non requise)

**Query Parameters:**
- `include_bets` (optionnel): `true` pour inclure les paris
- `bet_status` (optionnel): Filtrer les paris par statut
- `page` (optionnel): Page pour les paris
- `per_page` (optionnel): Éléments par page pour les paris

**Réponse (200):**
```json
{
  "data": {
    "id": 1,
    "session": "evening",
    "draw_date": "2025-11-20",
    "numbers": [12, 34, 45, 67, 89],
    "status": "completed"
  },
  "statistics": {
    "total_bets": 15,
    "winning_bets": 3,
    "losing_bets": 12,
    "total_wins": 5000.0,
    "total_wins_count": 3
  },
  "bets": {
    "meta": {...},
    "data": [...]
  }
}
```

---

### 13. Paris d'un tirage

**GET** `/api/v1/lotto_draws/:id/bets?status=won&page=1&per_page=20`

**Headers:**
```
Authorization: Bearer <token> // Optionnel - si authentifié, voit uniquement ses paris
Content-Type: application/json
```

**Query Parameters:**
- `status` (optionnel): Filtrer par statut (`pending`, `won`, `lost`, `cancelled`)
- `page` (optionnel): Numéro de page
- `per_page` (optionnel): Éléments par page

**Réponse (200):**
```json
{
  "draw_id": 1,
  "draw_date": "2025-11-20",
  "session": "evening",
  "numbers": [12, 34, 45, 67, 89],
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 15
  },
  "data": [
    {
      "id": 1,
      "numbers": [12, 23, 34, 45, 56],
      "amount": "150.0",
      "status": "won",
      "bet_reference": "BET-ABC123"
    }
  ]
}
```

---

## 🏆 Lotto - Gains

### 14. Mes gains

**GET** `/api/v1/lotto_wins?page=1&per_page=20`

**Headers:**
```
Authorization: Bearer <token>
```

**Query Parameters:**
- `page` (optionnel): Numéro de page
- `per_page` (optionnel): Éléments par page

**Réponse (200):**
```json
{
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 1,
    "total_count": 5
  },
  "data": [
    {
      "id": 1,
      "lotto_bet_id": 1,
      "lotto_draw_id": 1,
      "win_amount": "500.0",
      "matched_numbers": 2,
      "status": "credited",
      "credited_at": "2025-11-20T20:25:00.000Z"
    }
  ]
}
```

---

## 💳 Topups (Recharges)

### 15. Créer une recharge

**POST** `/api/v1/topups`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "amount": 5000.0,
  "payment_method": "mobile_money",
  "draft_data": {
    "phone": "+237612345678"
  }
}
```

**Réponse Succès (201):**
```json
{
  "message": "Topup initiated",
  "draft_id": 1
}
```

---

### 16. Confirmer une recharge

**PUT** `/api/v1/topups/confirm`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "draft_id": 1,
  "external_reference": "MTN-ABC123"
}
```

**Réponse Succès (200):**
```json
{
  "message": "Topup completed",
  "data": {
    "id": 1,
    "amount": "5000.0",
    "status": "completed"
  }
}
```

---

### 17. Liste des recharges

**GET** `/api/v1/topups?page=1&per_page=20`

**Headers:**
```
Authorization: Bearer <token>
```

**Réponse (200):**
```json
{
  "meta": {...},
  "data": [...]
}
```

---

## 💸 Withdrawals (Retraits)

### 18. Créer un retrait

**POST** `/api/v1/withdrawals`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "amount": 2000.0,
  "phone_number": "+237612345678",
  "draft_data": {}
}
```

**Réponse Succès (201):**
```json
{
  "message": "Withdrawal initiated",
  "draft_id": 1
}
```

---

### 19. Confirmer un retrait

**PUT** `/api/v1/withdrawals/confirm`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "draft_id": 1,
  "external_reference": "MTN-XYZ789"
}
```

---

### 20. Liste des retraits

**GET** `/api/v1/withdrawals?page=1&per_page=20`

**Headers:**
```
Authorization: Bearer <token>
```

---

## 📄 KYC

### 21. Soumettre une demande KYC

**POST** `/api/v1/kyc_requests`

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Body:**
```json
{
  "document_type": "cni",
  "document_number": "123456789",
  "documents": ["base64_encoded_image_1", "base64_encoded_image_2"]
}
```

**Réponse Succès (201):**
```json
{
  "message": "KYC submitted",
  "data": {
    "id": 1,
    "document_type": "cni",
    "status": "pending"
  }
}
```

---

### 22. Mes demandes KYC

**GET** `/api/v1/kyc_requests/show_by_client?page=1&per_page=20`

**Headers:**
```
Authorization: Bearer <token>
```

---

## 📊 Format des Réponses

### Réponse de Succès
```json
{
  "message": "Message de succès (optionnel)",
  "data": { ... }
}
```

### Réponse avec Pagination
```json
{
  "meta": {
    "current_page": 1,
    "per_page": 20,
    "total_pages": 5,
    "total_count": 100,
    "next_page": 2,
    "prev_page": null
  },
  "data": [ ... ]
}
```

### Réponse d'Erreur
```json
{
  "error": "Message d'erreur",
  "errors": ["Détail erreur 1", "Détail erreur 2"] // Optionnel
}
```

---

## 🔑 Codes de Statut HTTP

- `200 OK` - Succès
- `201 Created` - Ressource créée
- `400 Bad Request` - Requête invalide
- `401 Unauthorized` - Non authentifié
- `404 Not Found` - Ressource non trouvée
- `422 Unprocessable Entity` - Erreur de validation
- `500 Internal Server Error` - Erreur serveur

---

## 🔐 Authentification JWT

Tous les endpoints (sauf login, register, et certains endpoints de tirages) nécessitent un token JWT.

**Header:**
```
Authorization: Bearer <token>
```

Le token est retourné lors de la connexion ou de l'inscription et expire après 24 heures.

---

## 📝 Notes Importantes

1. **Format des dates:** `YYYY-MM-DD` (ex: `2025-11-20`)
2. **Format des nombres:** Tableau JSON `[12, 23, 34, 45, 56]`
3. **Montants:** Décimales avec 2 décimales (ex: `150.0`)
4. **Pagination:** Par défaut 20 éléments par page, maximum 100
5. **Sessions:** `"morning"` (09:00) ou `"evening"` (20:20 pour test)
6. **Fermeture des paris:** 5 minutes avant le tirage

---

## 🚀 Configuration Flutter

### Exemple de service API Flutter

```dart
class ApiService {
  final String baseUrl = 'http://localhost:3000/api/v1';
  String? token;

  Future<Map<String, dynamic>> login(String phone, String password) async {
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
      token = data['token'];
      return data;
    } else {
      throw Exception('Login failed');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    return jsonDecode(response.body);
  }
}
```

---

**Dernière mise à jour:** 2025-11-20

