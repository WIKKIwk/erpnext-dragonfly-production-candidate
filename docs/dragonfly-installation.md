# Dragonfly Installation

This repository does not redistribute Dragonfly binaries. The installer downloads Dragonfly from the official upstream GitHub releases.

Install the latest Dragonfly release:

```bash
./scripts/install-dragonfly.sh
```

Install a specific release:

```bash
DRAGONFLY_VERSION=v1.38.1 ./scripts/install-dragonfly.sh
```

Install to a custom directory:

```bash
INSTALL_DIR=/usr/local/bin ./scripts/install-dragonfly.sh
```

After installation:

```bash
dragonfly --version
```

Then configure ERPNext:

```bash
cp .env.example .env
vim .env
./scripts/bootstrap-erpnext-dragonfly.sh
```

## Why the Binary Is Not Committed

Dragonfly uses the Business Source License 1.1. To keep this repository clean and easy to audit, it ships only integration tooling and downloads Dragonfly from the official release source at install time.
