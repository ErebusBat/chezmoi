MODELS_DIR := env_var("HOME") / ".lmstudio" / "models"
EXT_HDD_MODELS_DIR := "/Volumes/SeaBack/llm/lm-studio/models"

# Sync models to external HDD
[group('Data')]
sync-to:
  rsync -av --progress {{ MODELS_DIR }}/ {{ EXT_HDD_MODELS_DIR }}/
