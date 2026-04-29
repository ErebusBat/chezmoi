MODELS_DIR := env_var("HOME") / ".lmstudio" / "models"
EXT_HDD_MODELS_DIR := "/Volumes/SeaBack/llm/lm-studio/models"

# Sync models to external HDD
[group('Data')]
sync-to:
  rsync -av --progress {{ MODELS_DIR }}/ {{ EXT_HDD_MODELS_DIR }}/

# Shows Disk Used/Free on Model Volumes
[group('Data')]
duf:
  #!/usr/bin/env zsh
  vols=("{{MODELS_DIR}}")
  ext_vol="{{EXT_HDD_MODELS_DIR}}"
  if [[ -d $ext_vol ]]; then
    vols+=("$ext_vol")
  else
    echo "***WARN: External HDD ($ext_vol) not plugged in"
  fi
  duf "${vols[@]}"
