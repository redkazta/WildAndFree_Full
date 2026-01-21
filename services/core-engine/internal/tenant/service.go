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
}

type InitResponse struct {
	Config Config   `json:"config"`
	Data   InitData `json:"data"`
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
		},
	}, true, nil
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

