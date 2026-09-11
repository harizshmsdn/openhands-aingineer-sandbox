# Open-source OpenHands runtime base image
FROM ghcr.io/openhands/agent-server:1.43.1-python

# Set up the Azure extension directory for global accessibility
ENV AZURE_EXTENSION_DIR=/opt/az-extensions
ENV AZURE_CORE_COLLECT_TELEMETRY=0

USER root

# Install system tools: build-essential, Node.js, Azure CLI, Pandoc, and jq.
# The Azure CLI installer has no Debian trixie repo and falls back to bookworm.
RUN apt-get update \
    && apt-get install -y --no-install-recommends ca-certificates curl pandoc jq build-essential \
    && curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && curl -sL https://aka.ms/InstallAzureCLIDeb | bash \
    && mkdir -p /opt/az-extensions \
    && az extension add --name communication \
    && chown -R openhands /opt/az-extensions \
    && rm -rf /var/lib/apt/lists/*

# Python tooling goes into the image's own Python 3.13 (/usr/local/bin/python) 
# The agent server is a self-contained binary with its own bundled interpreter

# Use docling-slim with explicit extras, NOT plain `docling` (an alias for
# docling-slim[standard]), which drags in torch/torchvision/transformers. 
# Add `models-local` to get those back
#   documents : docling-slim pypdf pdfplumber python-docx openpyxl xlsxwriter
#   templating: jinja2 premailer beautifulsoup4 html2text
#   mail      : azure-communication-email azure-identity msal imapclient extract-msg
#   data/http : pandas tabulate requests httpx python-dateutil
#   browser   : playwright
ENV PLAYWRIGHT_BROWSERS_PATH=/opt/ms-playwright
RUN pip install --no-cache-dir \
        "docling-slim[cli,convert-core,format-pdf-pypdfium2,format-office,format-email,format-html,format-markdown]" \
        pypdf pdfplumber python-docx openpyxl xlsxwriter \
        jinja2 premailer beautifulsoup4 html2text \
        azure-communication-email azure-identity msal imapclient extract-msg \
        pandas tabulate requests httpx python-dateutil \
        playwright \
    && playwright install --with-deps chromium \
    && chmod -R a+rX /opt/ms-playwright

# Runtime `pip install` goes to ~/.local, since site-packages is root-owned.
# (The agent also has passwordless sudo if it genuinely needs a system package.)
ENV PIP_USER=1

# Drop back to the base image's unprivileged user
USER openhands
