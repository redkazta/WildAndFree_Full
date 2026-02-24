package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"
	"time"

	"github.com/joho/godotenv"

	"core-engine/internal/spotify"
	"core-engine/internal/tenant"
	"core-engine/internal/database"
	"core-engine/internal/commerce"
)

type HealthStatus struct {
	Status    string `json:"status"`
	Engine    string `json:"engine"`
	Crew      string `json:"crew"`
	Timestamp string `json:"timestamp"`
}

type Artist struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Role     string `json:"role"`
	ImageURL string `json:"image_url"`
}

func main() {
	// Load environment variables
	if err := godotenv.Load(); err != nil {
		log.Println("No .env file found, using system environment variables")
	}

	// Initialize Database
	if err := database.Init(); err != nil {
		log.Printf("Database initialization failed: %v", err)
	} else {
		log.Println("Database initialized successfully")
	}

	mux := http.NewServeMux()

	// Spotify Client
	spotifyClientID := os.Getenv("SPOTIFY_CLIENT_ID")
	spotifyClientSecret := os.Getenv("SPOTIFY_CLIENT_SECRET")
	var spotifyClient *spotify.Client
	if spotifyClientID != "" && spotifyClientSecret != "" {
		spotifyClient = spotify.NewClient(spotifyClientID, spotifyClientSecret)
		log.Println("Spotify Client initialized")
	} else {
		log.Println("Spotify Client NOT initialized (missing env vars)")
	}

	// Setup tag handlers
	setupTagHandlers(mux)

	mux.HandleFunc("GET /api/v1/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")

		payload := HealthStatus{
			Status:    "live",
			Engine:    "Go",
			Crew:      "Wild and Free",
			Timestamp: time.Now().UTC().Format(time.RFC3339),
		}

		_ = json.NewEncoder(w).Encode(payload)
	})

	mux.HandleFunc("GET /api/v1/artists", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")

		payload := []Artist{
			{
				ID:       "a1",
				Name:     "Nova K",
				Role:     "Rapper",
				ImageURL: "https://images.unsplash.com/photo-1520975958221-7f61d4d6df4b?auto=format&fit=crop&w=800&q=80",
			},
			{
				ID:       "a2",
				Name:     "Sable",
				Role:     "Producer",
				ImageURL: "https://images.unsplash.com/photo-1520975693413-35e0000c0e4e?auto=format&fit=crop&w=800&q=80",
			},
			{
				ID:       "a3",
				Name:     "Mira V",
				Role:     "DJ",
				ImageURL: "https://images.unsplash.com/photo-1520975753545-c9a7d1551b77?auto=format&fit=crop&w=800&q=80",
			},
		}

		_ = json.NewEncoder(w).Encode(payload)
	})

	mux.HandleFunc("GET /api/v1/tenant/{id}/init", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")

		tenantID := r.PathValue("id")
		payload, ok, err := tenant.LoadInit(tenantID)
		if err != nil {
			http.Error(w, "failed to load tenant", http.StatusInternalServerError)
			return
		}
		if !ok {
			http.Error(w, "tenant not found", http.StatusNotFound)
			return
		}

		_ = json.NewEncoder(w).Encode(payload)
	})

	mux.HandleFunc("GET /api/v1/spotify/search", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json; charset=utf-8")
		// Enable CORS for local dev
		w.Header().Set("Access-Control-Allow-Origin", "*")

		if spotifyClient == nil {
			http.Error(w, "spotify client not configured", http.StatusServiceUnavailable)
			return
		}

		query := r.URL.Query().Get("q")
		if query == "" {
			http.Error(w, "missing query parameter 'q'", http.StatusBadRequest)
			return
		}

		result, err := spotifyClient.Search(query)
		if err != nil {
			log.Printf("Spotify Search Error: %v", err)
			http.Error(w, "failed to search spotify", http.StatusInternalServerError)
			return
		}

		_ = json.NewEncoder(w).Encode(result)
	})

	// Commerce Handlers (Cart & Wishlist)
	mux.HandleFunc("GET /api/v1/cart", commerce.HandleGetCart)
	mux.HandleFunc("POST /api/v1/cart/add", commerce.HandleAddToCart)
	mux.HandleFunc("DELETE /api/v1/cart/remove", commerce.HandleRemoveFromCart)

	mux.HandleFunc("GET /api/v1/wishlist", commerce.HandleGetWishlist)
	mux.HandleFunc("POST /api/v1/wishlist/add", commerce.HandleAddToWishlist)
	mux.HandleFunc("DELETE /api/v1/wishlist/remove", commerce.HandleRemoveFromWishlist)

	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	server := &http.Server{
		Addr:              ":" + port,
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Printf("Core Engine Starting on port %s...", port)
	log.Fatal(server.ListenAndServe())
}
