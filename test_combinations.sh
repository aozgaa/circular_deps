#!/usr/bin/env bash
set -u -o pipefail

show_usage() {
  cat <<USAGE
Usage: $(basename "$0") --results <file>

Run library-kind combinations across circular-dependency scenarios and emit a CSV summary.

Options:
  --results <file>  Output CSV file (required)
  -h, --help        Show this message
USAGE
}

# Parse options
results_file=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --results)
      results_file="$2"
      shift 2
      ;;
    -h|--help)
      show_usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      show_usage >&2
      exit 1
      ;;
  esac
done

if [[ -z "$results_file" ]]; then
  echo "error: --results is required" >&2
  show_usage >&2
  exit 1
fi

scenarios=(
  "cmake_lib_kinds"
  "missing_dep-one_source"
  "missing_dep-multi_source"
)

kinds=(STATIC SHARED OBJECT)

log(){ printf '[%s][%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "$(basename "$0")" "$*"; }

# CSV header
printf 'scenario,a_kind,b_kind,configure,build,run\n' >"$results_file"

for scenario in "${scenarios[@]}"; do
  for a_kind in "${kinds[@]}"; do
    for b_kind in "${kinds[@]}"; do
      build_dir="$scenario/build-${a_kind}-${b_kind}"
      log "Scenario=$scenario A_KIND=$a_kind B_KIND=$b_kind"

      rm -rf "$build_dir"
      mkdir -p "$build_dir"

      configure_status="fail"
      build_status="skip"
      run_status="skip"

      if env A_KIND="$a_kind" B_KIND="$b_kind" cmake -S "$scenario" -B "$build_dir"; then
        configure_status="ok"
        if env A_KIND="$a_kind" B_KIND="$b_kind" cmake --build "$build_dir"; then
          build_status="ok"
          exe="$build_dir/main"
          if [[ -x "$exe" ]]; then
            if env A_KIND="$a_kind" B_KIND="$b_kind" "$exe" >/dev/null 2>&1; then
              run_status="ok"
            else
              run_status="fail"
            fi
          else
            run_status="missing"
          fi
        else
          build_status="fail"
        fi
      else
        configure_status="fail"
      fi

      printf '%s,%s,%s,%s,%s,%s\n' "$scenario" "$a_kind" "$b_kind" "$configure_status" "$build_status" "$run_status" >>"$results_file"
    done
  done
done

log "Results written to $results_file"
