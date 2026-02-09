package main

import (
	"database/sql"
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

type Tag struct {
	ID        int    `json:"id"`
	Name      string `json:"name"`
	Color     string `json:"color"`
	Animation string `json:"animation"`
}

type UserTag struct {
	TagID     int    `json:"tag_id"`
	TagName   string `json:"tag_name"`
	Color     string `json:"color"`
	Animation string `json:"animation"`
}

func main() {
	mux := http.NewServeMux()

	// Obtener tags de un usuario
	mux.HandleFunc("GET /api/v1/users/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		// Extraer userID del path
		path := r.URL.Path[len("/api/v1/users/"):]
		
		// Buscar el patrón /{userID}/tags
		var userID string
		for i := len(path) - 1; i >= 0; i-- {
			if path[i] == '/' {
				if path[i+1:] == "tags" {
					userID = path[:i]
					break
				}
			}
		}

		if userID == "" {
			http.Error(w, "Invalid user ID", http.StatusBadRequest)
			return
		}

		tags, err := getUserTags(userID)
		if err != nil {
			log.Printf("Error getting user tags: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"tags": tags,
		})
	})

	// Obtener todos los tags disponibles
	mux.HandleFunc("GET /api/v1/tags", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		tags, err := getAllTags()
		if err != nil {
			log.Printf("Error getting all tags: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"tags": tags,
		})
	})

	// Asignar tag a usuario
	mux.HandleFunc("POST /api/v1/users/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		// Extraer userID y tagID del path
		path := r.URL.Path[len("/api/v1/users/"):]
		
		// Buscar el patrón /{userID}/tags/{tagID}
		var userID string
		var tagID int
		
		for i := len(path) - 1; i >= 0; i-- {
			if path[i] == '/' {
				if i > 5 && path[i-5:i] == "tags/" {
					userID = path[:i-6]
					fmt.Sscanf(path[i+1:], "%d", &tagID)
					break
				}
			}
		}

		if userID == "" || tagID == 0 {
			http.Error(w, "Invalid user ID or tag ID", http.StatusBadRequest)
			return
		}

		err := assignTagToUser(userID, tagID)
		if err != nil {
			log.Printf("Error assigning tag to user: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"status": "success"})
	})

	// Remover tag de usuario
	mux.HandleFunc("DELETE /api/v1/users/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodDelete {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		// Extraer userID y tagID del path
		path := r.URL.Path[len("/api/v1/users/"):]
		
		// Buscar el patrón /{userID}/tags/{tagID}
		var userID string
		var tagID int
		
		for i := len(path) - 1; i >= 0; i-- {
			if path[i] == '/' {
				if i > 5 && path[i-5:i] == "tags/" {
					userID = path[:i-6]
					fmt.Sscanf(path[i+1:], "%d", &tagID)
					break
				}
			}
		}

		if userID == "" || tagID == 0 {
			http.Error(w, "Invalid user ID or tag ID", http.StatusBadRequest)
			return
		}

		err := removeTagFromUser(userID, tagID)
		if err != nil {
			log.Printf("Error removing tag from user: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"status": "success"})
	})

	// Crear nuevo tag (solo admin)
	mux.HandleFunc("POST /api/v1/tags", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodPost {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		var tag Tag
		err := json.NewDecoder(r.Body).Decode(&tag)
		if err != nil {
			http.Error(w, "Invalid request body", http.StatusBadRequest)
			return
		}

		// Validar campos requeridos
		if tag.Name == "" || tag.Color == "" || tag.Animation == "" {
			http.Error(w, "Missing required fields", http.StatusBadRequest)
			return
		}

		newTag, err := createTag(tag.Name, tag.Color, tag.Animation)
		if err != nil {
			log.Printf("Error creating tag: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(newTag)
	})

	// Eliminar tag (solo admin)
	mux.HandleFunc("DELETE /api/v1/tags/", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodDelete {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		// Extraer tagID del path
		tagIDStr := r.URL.Path[len("/api/v1/tags/"):]
		if tagIDStr == "" {
			http.Error(w, "Invalid tag ID", http.StatusBadRequest)
			return
		}

		var tagID int
		_, err := fmt.Sscanf(tagIDStr, "%d", &tagID)
		if err != nil {
			http.Error(w, "Invalid tag ID format", http.StatusBadRequest)
			return
		}

		err = deleteTag(tagID)
		if err != nil {
			log.Printf("Error deleting tag: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]string{"status": "success"})
	})

	// Obtener usuarios con sus tags (para admin)
	mux.HandleFunc("GET /api/v1/admin/users-with-tags", func(w http.ResponseWriter, r *http.Request) {
		if r.Method != http.MethodGet {
			http.Error(w, "Method not allowed", http.StatusMethodNotAllowed)
			return
		}

		usersWithTags, err := getUsersWithTags()
		if err != nil {
			log.Printf("Error getting users with tags: %v", err)
			http.Error(w, "Internal server error", http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		json.NewEncoder(w).Encode(map[string]interface{}{
			"users": usersWithTags,
		})
	})

	log.Println("Server starting on :8080")
	if err := http.ListenAndServe(":8080", mux); err != nil {
		log.Fatal(err)
	}
}

func getUserTags(userID string) ([]UserTag, error) {
	db, err := sql.Open("postgres", getDatabaseURL())
	if err != nil {
		return nil, err
	}
	defer db.Close()

	query := `
		SELECT t.id, t.name, t.color, t.animation
		FROM tags t
		JOIN user_has_tags uht ON t.id = uht.tag_id
		WHERE uht.user_id = $1
		ORDER BY t.name
	`

	rows, err := db.Query(query, userID)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tags []UserTag
	for rows.Next() {
		var tag UserTag
		err := rows.Scan(&tag.TagID, &tag.TagName, &tag.Color, &tag.Animation)
		if err != nil {
			return nil, err
		}
		tags = append(tags, tag)
	}

	return tags, nil
}

func getAllTags() ([]Tag, error) {
	db, err := sql.Open("postgres", getDatabaseURL())
	if err != nil {
		return nil, err
	}
	defer db.Close()

	query := `
		SELECT id, name, color, animation
		FROM tags
		ORDER BY name
	`

	rows, err := db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var tags []Tag
	for rows.Next() {
		var tag Tag
		err := rows.Scan(&tag.ID, &tag.Name, &tag.Color, &tag.Animation)
		if err != nil {
			return nil, err
		}
		tags = append(tags, tag)
	}

	return tags, nil
}

func assignTagToUser(userID string, tagID int) error {
	db, err := sql.Open("postgres", getDatabaseURL())
	if err != nil {
		return err
	}
	defer db.Close()

	query := `
		INSERT INTO user_has_tags (user_id, tag_id)
		VALUES ($1, $2)
		ON CONFLICT (user_id, tag_id) DO NOTHING
	`

	_, err = db.Exec(query, userID, tagID)
	return err
}

func removeTagFromUser(userID string, tagID int) error {
	db, err := sql.Open("postgres", getDatabaseURL())
	if err != nil {
		return err
	}
	defer db.Close()

	query := `
		DELETE FROM user_has_tags
		WHERE user_id = $1 AND tag_id = $2
	`

	_, err = db.Exec(query, userID, tagID)
	return err
}

func createTag(name, color, animation string) (*Tag, error) {
	db, err := sql.Open("postgres", getDatabaseURL())
	if err != nil {
		return nil, err
	}
	defer db.Close()

	query := `
		INSERT INTO tags (name, color, animation)
		VALUES ($1, $2, $3)
		RETURNING id, name, color, animation
	`

	var tag Tag
	err = db.QueryRow(query, name, color, animation).Scan(&tag.ID, &tag.Name, &tag.Color, &tag.Animation)
	if err != nil {
		return nil, err
	}

	return &tag, nil
}

func deleteTag(tagID int) error {
	db, err := sql.Open("postgres", getDatabaseURL())
	if err != nil {
		return err
	}
	defer db.Close()

	// Primero eliminar las relaciones en user_has_tags
	query1 := `DELETE FROM user_has_tags WHERE tag_id = $1`
	_, err = db.Exec(query1, tagID)
	if err != nil {
		return err
	}

	// Luego eliminar el tag
	query2 := `DELETE FROM tags WHERE id = $1`
	_, err = db.Exec(query2, tagID)
	return err
}

type UserWithTags struct {
	UserID   string    `json:"id"`
	UserName string    `json:"username"`
	Role     string    `json:"role"`
	Tags     []UserTag `json:"tags"`
}

func getUsersWithTags() ([]UserWithTags, error) {
	db, err := sql.Open("postgres", getDatabaseURL())
	if err != nil {
		return nil, err
	}
	defer db.Close()

	// Obtener usuarios desde profiles y sus roles
	query := `
		SELECT p.id, COALESCE(p.username, 'Unknown') as username, COALESCE(r.name, 'fan') as role
		FROM profiles p
		LEFT JOIN user_has_roles uhr ON p.id = uhr.user_id
		LEFT JOIN roles r ON uhr.role_id = r.id
		ORDER BY p.username
	`

	rows, err := db.Query(query)
	if err != nil {
		return nil, err
	}
	defer rows.Close()

	var usersWithTags []UserWithTags
	for rows.Next() {
		var user UserWithTags
		err := rows.Scan(&user.UserID, &user.UserName, &user.Role)
		if err != nil {
			return nil, err
		}

		// Obtener los tags de este usuario
		tags, err := getUserTags(user.UserID)
		if err != nil {
			// Si falla obtener tags, continuamos con lista vacía
			user.Tags = []UserTag{}
		} else {
			user.Tags = tags
		}

		usersWithTags = append(usersWithTags, user)
	}

	return usersWithTags, nil
}

func getDatabaseURL() string {
	url := os.Getenv("DATABASE_URL")
	if url == "" {
		// Fallback local por defecto
		return "postgres://postgres:postgres@localhost:5432/postgres?sslmode=disable"
	}
	return url
}
