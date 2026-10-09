#!/usr/bin/env bash
# Copies each template's HTML documentation into web/template-docs/ so the site
# serves it at /template-docs/<name>/. Run after editing a template's doc/.
set -euo pipefail
cd "$(dirname "$0")/.."
for doc in templates/*/doc/index.html; do
  name="$(basename "$(dirname "$(dirname "$doc")")")"
  mkdir -p "web/template-docs/$name"
  cp "$doc" "web/template-docs/$name/index.html"
  echo "synced $name"
done
