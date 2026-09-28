# OpenHands Custom Sandbox

Custom sandbox runtime image for OpenHands agents. This container extends the official Python agent server image with Azure integration tools, document processing libraries, and browser automation capabilities.

## Base Image

* **Source**: `ghcr.io/openhands/agent-server:1.43.1-python`
* **Default User**: `openhands` (unprivileged)
* **Python Runtime**: Python 3.13 (`/usr/local/bin/python`)

## Installed Components

### System Tools & Runtimes
* **Node.js**: 20.x LTS via NodeSource
* **Azure CLI**: Latest release with the `communication` extension installed globally at `/opt/az-extensions`
* **Utilities**: `git`, `dnsutils`, `jq`, `pandoc`, `curl`, `ca-certificates`, `build-essential`

### Python Libraries
* **Document Processing**: `docling-slim` (core converters, PDF, Office, email, HTML, markdown), `pypdf`, `pdfplumber`, `python-docx`, `openpyxl`, `xlsxwriter`
* **HTML & Templating**: `jinja2`, `premailer`, `beautifulsoup4`, `html2text`
* **Azure & Mail**: `azure-communication-email`, `azure-identity`, `msal`, `imapclient`, `extract-msg`
* **Data & Networking**: `pandas`, `tabulate`, `requests`, `httpx`, `python-dateutil`
* **Browser Automation**: `playwright` with Chromium binary pre-installed in `/opt/ms-playwright`
* **OSINT & Search**: `duckduckgo-search`, `theHarvester` (4.11.1)

## Environment Configuration

* `AZURE_EXTENSION_DIR=/opt/az-extensions`: Ensures global availability of Azure CLI extensions for the runtime user.
* `AZURE_CORE_COLLECT_TELEMETRY=0`: Disables telemetry collection.
* `PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright`: Points Playwright to pre-installed browser binaries with global read/execute permissions.
* `PIP_USER=1`: Directs runtime `pip install` commands to `~/.local` so packages can be installed without root privileges.

## Building the Image

### Local Build (Single Architecture)
```bash
# Build amd64 image locally
docker build --platform linux/amd64 -t openhands-custom-container:latest .
```

### Multi-Architecture Build (Buildx)
```bash
# Build and push multi-arch image
docker buildx build --platform linux/amd64,linux/arm64 \
  -t <registry>/<repo>:<tag> --push .
```

