#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(CDPATH="" cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../lib/vocastock_env.sh"

reuse_running=0
with_application_containers=0

for arg in "$@"; do
  case "$arg" in
    --reuse-running)
      reuse_running=1
      ;;
    --with-application-containers)
      with_application_containers=1
      ;;
    *)
      vocas_die "unsupported argument: $arg"
      ;;
  esac
done

vocas_log "validating local stack against Firebase services: ${VOCAS_FIREBASE_EMULATOR_SERVICES}"
bash "$SCRIPT_DIR/validate_local_setup.sh"

smoke_args=()
if (( reuse_running == 1 )); then
  smoke_args+=(--reuse-running)
fi
if (( with_application_containers == 1 )); then
  bash "$SCRIPT_DIR/validate_application_containers.sh"
  smoke_args+=(--with-application-containers)
fi

bash "$SCRIPT_DIR/../ci/run_local_stack_smoke.sh" "${smoke_args[@]}"

if (( with_application_containers == 1 )); then
  summary_file="$(vocas_application_smoke_summary_file)"
  [[ -f "$summary_file" ]] || vocas_die "missing application smoke summary: $summary_file"

  while IFS= read -r validation_scenario; do
    grep -q "^explanation_worker_validation.${validation_scenario}=" "$summary_file" \
      || vocas_die "missing explanation-worker validation record for ${validation_scenario}"
  done < <(vocas_explanation_worker_validation_scenarios)

  while IFS= read -r validation_scenario; do
    grep -q "^image_worker_validation.${validation_scenario}=" "$summary_file" \
      || vocas_die "missing image-worker validation record for ${validation_scenario}"
  done < <(vocas_image_worker_validation_scenarios)
fi

vocas_log "local stack validation passed"
