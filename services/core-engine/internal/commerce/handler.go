package commerce

import (
	"database/sql"
	"encoding/json"
	"net/http"
	"strings"
	"time"

	"core-engine/internal/database"
)

// -- Structs --

type CartItem struct {
	ID        string          `json:"id"`
	ProductID string          `json:"product_id"`
	Quantity  int             `json:"quantity"`
	Metadata  json.RawMessage `json:"metadata"`
	CreatedAt time.Time       `json:"created_at"`
}

type WishlistItem struct {
	ID        string          `json:"id"`
	ProductID string          `json:"product_id"`
	Metadata  json.RawMessage `json:"metadata"`
	CreatedAt time.Time       `json:"created_at"`
}

type AddToCartRequest struct {
	ProductID string          `json:"product_id"`
	Quantity  int             `json:"quantity"`
	Metadata  json.RawMessage `json:"metadata"`
}

type AddToWishlistRequest struct {
	ProductID string          `json:"product_id"`
	Metadata  json.RawMessage `json:"metadata"`
}

// -- Handlers --

// Helper to get User ID from header (Mock for now, should be JWT middleware)
func getUserID(r *http.Request) string {
	// TODO: Implement proper JWT validation middleware
	// For now, we expect the gateway or frontend to send a trusted header or token
	// This is a placeholder. In production, verify the Bearer token.
	authHeader := r.Header.Get("Authorization")
	if authHeader == "" {
		return ""
	}
	// Simplified: assuming "Bearer <uid>" for prototype (REPLACE WITH REAL JWT PARSING)
	parts := strings.Split(authHeader, " ")
	if len(parts) == 2 {
		return parts[1]
	}
	return ""
}

// Cart Handlers

func HandleGetCart(w http.ResponseWriter, r *http.Request) {
	userID := getUserID(r)
	if userID == "" {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	rows, err := database.DB.Query(`
		SELECT id, product_id, quantity, metadata, created_at 
		FROM cart_items 
		WHERE user_id = $1`, userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	items := []CartItem{}
	for rows.Next() {
		var i CartItem
		if err := rows.Scan(&i.ID, &i.ProductID, &i.Quantity, &i.Metadata, &i.CreatedAt); err != nil {
			continue
		}
		items = append(items, i)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(items)
}

func HandleAddToCart(w http.ResponseWriter, r *http.Request) {
	userID := getUserID(r)
	if userID == "" {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var req AddToCartRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	// Upsert logic
	_, err := database.DB.Exec(`
		INSERT INTO cart_items (user_id, product_id, quantity, metadata)
		VALUES ($1, $2, $3, $4)
		ON CONFLICT (user_id, product_id) 
		DO UPDATE SET quantity = cart_items.quantity + $3, updated_at = now()`,
		userID, req.ProductID, req.Quantity, req.Metadata)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"ok"}`))
}

func HandleRemoveFromCart(w http.ResponseWriter, r *http.Request) {
	userID := getUserID(r)
	if userID == "" {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	productID := r.URL.Query().Get("product_id")
	if productID == "" {
		http.Error(w, "Missing product_id", http.StatusBadRequest)
		return
	}

	_, err := database.DB.Exec("DELETE FROM cart_items WHERE user_id = $1 AND product_id = $2", userID, productID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"ok"}`))
}

// Wishlist Handlers

func HandleGetWishlist(w http.ResponseWriter, r *http.Request) {
	userID := getUserID(r)
	if userID == "" {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	rows, err := database.DB.Query(`
		SELECT id, product_id, metadata, created_at 
		FROM wishlist_items 
		WHERE user_id = $1`, userID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}
	defer rows.Close()

	items := []WishlistItem{}
	for rows.Next() {
		var i WishlistItem
		if err := rows.Scan(&i.ID, &i.ProductID, &i.Metadata, &i.CreatedAt); err != nil {
			continue
		}
		items = append(items, i)
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(items)
}

func HandleAddToWishlist(w http.ResponseWriter, r *http.Request) {
	userID := getUserID(r)
	if userID == "" {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	var req AddToWishlistRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, "Invalid request body", http.StatusBadRequest)
		return
	}

	_, err := database.DB.Exec(`
		INSERT INTO wishlist_items (user_id, product_id, metadata)
		VALUES ($1, $2, $3)
		ON CONFLICT (user_id, product_id) DO NOTHING`,
		userID, req.ProductID, req.Metadata)

	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"ok"}`))
}

func HandleRemoveFromWishlist(w http.ResponseWriter, r *http.Request) {
	userID := getUserID(r)
	if userID == "" {
		http.Error(w, "Unauthorized", http.StatusUnauthorized)
		return
	}

	productID := r.URL.Query().Get("product_id")
	if productID == "" {
		http.Error(w, "Missing product_id", http.StatusBadRequest)
		return
	}

	_, err := database.DB.Exec("DELETE FROM wishlist_items WHERE user_id = $1 AND product_id = $2", userID, productID)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"ok"}`))
}
