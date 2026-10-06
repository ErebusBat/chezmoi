# Android development: use Tilldone's JDK 17 when JAVA_HOME is not already set.
if [[ -z "${JAVA_HOME:-}" && -x "$HOME/.local/share/tilldone/jdk-17/bin/java" ]]; then
  export JAVA_HOME="$HOME/.local/share/tilldone/jdk-17"
fi
