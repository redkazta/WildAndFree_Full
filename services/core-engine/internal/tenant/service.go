package tenant

import (
	"encoding/json"
	"os"
	"path/filepath"
	"runtime"
)

type Config struct {
	ID             string          `json:"id"`
	Name           string          `json:"name"`
	PrimaryColor   string          `json:"primary_color"`
	SecondaryColor string          `json:"secondary_color"`
	Modules        map[string]bool `json:"modules"`
}

type InitData struct {
	CrewName string `json:"crew_name"`
	Artists  []Artist `json:"artists"`
}

type InitResponse struct {
	Config Config   `json:"config"`
	Data   InitData `json:"data"`
}

type Artist struct {
	ID       string `json:"id"`
	Name     string `json:"name"`
	Role     string `json:"role"`
	ImageURL string `json:"image_url"`
}

func LoadInit(tenantID string) (InitResponse, bool, error) {
	configs, err := loadConfigs()
	if err != nil {
		return InitResponse{}, false, err
	}

	cfg, ok := configs[tenantID]
	if !ok {
		return InitResponse{}, false, nil
	}

	return InitResponse{
		Config: cfg,
		Data: InitData{
			CrewName: cfg.Name,
			Artists:  mockArtists(tenantID),
		},
	}, true, nil
}

func mockArtists(tenantID string) []Artist {
	if tenantID == "wild-and-free" {
		return []Artist{
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
				Role:     "Rapper",
				ImageURL: "https://images.unsplash.com/photo-1542291026-7eec264c27ff?auto=format&fit=crop&w=800&q=80",
			},
			{
				ID:       "a4",
				Name:     "Kairo",
				Role:     "DJ",
				ImageURL: "https://images.unsplash.com/photo-1520975753545-c9a7d1551b77?auto=format&fit=crop&w=800&q=80",
			},
		}
	}

	return []Artist{
		{
			ID:       "a1",
			Name:     "Unknown",
			Role:     "Artist",
			ImageURL: "https://images.unsplash.com/photo-1520975958221-7f61d4d6df4b?auto=format&fit=crop&w=800&q=80",
		},
	}
}

func loadConfigs() (map[string]Config, error) {
	_, file, _, ok := runtime.Caller(0)
	if !ok {
		return nil, os.ErrInvalid
	}

	internalTenantDir := filepath.Dir(file)
	repoRoot := filepath.Clean(filepath.Join(internalTenantDir, "..", "..", "..", ".."))
	configPath := filepath.Join(repoRoot, "packages", "shared-types", "tenant-config.json")

	raw, err := os.ReadFile(configPath)
	if err != nil {
		return nil, err
	}

	var configs map[string]Config
	if err := json.Unmarshal(raw, &configs); err != nil {
		return nil, err
	}

	return configs, nil
}
