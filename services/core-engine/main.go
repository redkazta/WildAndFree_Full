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

func main() {
	mux := http.NewServeMux()

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
