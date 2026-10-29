#!/usr/bin/env bash
set -euo pipefail

root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${root}"

terraform fmt -check -recursive

init_and_validate() {
  local dir="$1"
  echo "validate ${dir}"
  terraform -chdir="${dir}" init -backend=false -input=false -no-color
  terraform -chdir="${dir}" validate -no-color
}

init_and_validate "${root}"

for dir in "${root}"/modules/*; do
  init_and_validate "${dir}"
done
