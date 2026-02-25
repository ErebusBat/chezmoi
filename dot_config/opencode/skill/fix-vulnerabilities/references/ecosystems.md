# Ecosystem-Specific Validation & Fix Strategies

## Validation Commands

### Rust (cargo)

```bash
cargo tree -p <package-name>
```

### Go

```bash
go list -m all | grep <package-name>
```

### Python (pip/poetry/pipenv)

```bash
pip show <package-name>
# or
poetry show <package-name>
```

### Ruby (bundler)

```bash
bundle show <gem-name>
```

### PHP (composer)

```bash
composer show <package-name>
```

## Fix Strategies

### Rust (cargo)

```bash
cargo update -p <package-name>
```

If that doesn't work, edit `Cargo.toml` to specify minimum version or use `[patch]` section.

### Go

```bash
go get <package>@v<patched-version>
go mod tidy
```

### Python

**pip:**

```bash
pip install --upgrade <package-name>>=<patched-version>
pip freeze > requirements.txt
```

**poetry:**

```bash
poetry update <package-name>
```

**pipenv:**

```bash
pipenv update <package-name>
```

### Ruby (bundler)

```bash
bundle update <gem-name>
```

Or edit `Gemfile` to specify minimum version.

### PHP (composer)

```bash
composer update <package-name>
```

## Quality Check Commands by Ecosystem

| Ecosystem  | Common Check Commands                             |
| ---------- | ------------------------------------------------- |
| cargo      | `cargo check`, `cargo test`, `cargo clippy`       |
| go         | `go build ./...`, `go test ./...`, `go vet ./...` |
| poetry/pip | `pytest`, `mypy`, `flake8`, `ruff`                |
| bundler    | `bundle exec rspec`, `bundle exec rubocop`        |
| composer   | `composer test`, `phpunit`, `phpstan`             |
