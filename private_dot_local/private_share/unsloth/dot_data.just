# MODELS_DIR := env_var("HOME") / ".lmstudio" / "models"
# EXT_HDD_MODELS_DIR := "/Volumes/SeaBack/llm/lm-studio/models"

MODELS_DIR := HF_HUB_CACHE_ROOT
EXT_ROOT := '/Volumes/SeaBack/llm/unsloth'
EXT_HDD_MODELS_DIR := EXT_ROOT / 'models'

# Sync models to external HDD
[group('Data')]
sync-to:
    rsync -av --progress \
       --exclude 'downloading_*' \
       --exclude '.cache/' \
       --exclude '.locks/' \
       --exclude '*.part' \
       {{ MODELS_DIR }}/ {{ EXT_HDD_MODELS_DIR }}/

# List models (dirs) in external HDD Path
[group('Data')]
ls-model-files-ext:
    fd --type d . "{{ EXT_HDD_MODELS_DIR }}" | sort

# List models (dirs) in local path
[group('Data')]
ls-model-files-local provider='':
    # fd --type d . "{{ MODELS_DIR }}" | sort
    command eza -Tlh -L 3 -s name --icons=auto "{{ MODELS_DIR / provider }}"

# Shows Disk Used/Free on Model Volumes
[group('Data')]
duf:
    #!/usr/bin/env zsh
    vols=("{{ MODELS_DIR }}")
    ext_vol="{{ EXT_HDD_MODELS_DIR }}"
    if [[ -d $ext_vol ]]; then
      vols+=("$ext_vol")
    else
      echo "***WARN: External HDD ($ext_vol) not plugged in"
    fi
    duf "${vols[@]}"

