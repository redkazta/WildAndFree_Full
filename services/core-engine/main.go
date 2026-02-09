package main

import (
	"encoding/json"
	"log"
	"net/http"
	"time"

	"core-engine/internal/tenant"
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
	mux := http.NewServeMux()

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

	server := &http.Server{
		Addr:              ":8080",
		Handler:           mux,
		ReadHeaderTimeout: 5 * time.Second,
	}

	log.Println("Core Engine Starting...")
	log.Fatal(server.ListenAndServe())
}
