## Domain glossary

- **Primary file** — File A; the YAML source whose eligible fields are considered for merge.
- **Secondary file** — File B; the YAML document receiving the result.
- **Excluded path** — An exact dotted mapping path, including nested mappings (for example, `database.host`), supplied once per `--exclude PATH` argument; its value must not be taken from the Primary file.
- **Merge precedence** — For every non-excluded conflicting top-level key, the Primary value replaces the Secondary value. Secondary-only keys remain in the result.
- **Selective mapping merge** — For a mapping containing a nested excluded path, merge mapping entries recursively: retain the Secondary value at excluded paths, use the Primary value at non-excluded conflicts, and retain Secondary-only nested entries.
- **Atomic replacement** — Write the serialized result to a temporary file in the Secondary file's directory and rename it over the Secondary only after serialization succeeds; do not retain a backup.
