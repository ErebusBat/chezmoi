MODELS_DIR := env_var("HOME") / ".lmstudio" / "models"
EXT_HDD_MODELS_DIR := "/Volumes/SeaBack/llm/lm-studio/models"

# Sync models to external HDD
[group('Data')]
sync-to:
  rsync -av --progress {{ MODELS_DIR }}/ {{ EXT_HDD_MODELS_DIR }}/

# List models (dirs) in external HDD Path
[group('Data')]
ls-model-files-ext:
  fd --type d . "{{ EXT_HDD_MODELS_DIR }}"

# List models (dirs) in local path
[group('Data')]
ls-model-files-local:
  fd --type d . "{{ MODELS_DIR }}"

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

# Back up LM Studio model caches so they rebuild on next launch
[group('Data')]
clear-model-caches:
  #!/usr/bin/env zsh
  cache_dir="${HOME}/.lmstudio/.internal"
  ts="$(date +%Y%m%d%H%M%S)"
  for file in model-index-cache.json model-data.json gguf-metadata-cache.json; do
    src="${cache_dir}/${file}"
    if [[ -e "${src}" ]]; then
      mv "${src}" "${src}.bak.${ts}"
      echo "Backed up ${src} -> ${src}.bak.${ts}"
    else
      echo "Skipping missing ${src}"
    fi
  done
