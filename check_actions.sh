#!/bin/bash

# shellcheck disable=SC2001
log_info() {
  echo "$@" | sed 's/^/INFO:\t/'
}

# shellcheck disable=SC2001
log_err() {
  echo "$@" | sed 's/^/ERROR:\t/' >&2
}

check_actions() {
  local workflows=()
  local result=0
  local checks=(permissions timeouts versions)

  for p in '*.yml' '*.yaml'; do
    # shellcheck disable=SC2206,SC2086
    stat $p &>/dev/null && workflows+=($p)
  done

  local wf wf_content check result check_cmd env_param

  for wf in "${workflows[@]}"; do
    wf_content=$(cat "$wf")

    log_info "Checking $wf"
    for check in "${checks[@]}"; do
      check_cmd="check_actions_$check"
      env_param=${check_cmd^^}

      [[ "${!env_param-true}" == "true" ]] || continue

      "$check_cmd" <<< "$wf_content" && check_result=$? || check_result=$?

      if (( check_result != 0 )); then
        result=1
        log_err "$wf - $check check failed"
        continue
      fi

      log_info "$wf - $check check succeeded"
    done

    echo
  done

  return "$result"
}

check_actions_permissions() {
  local yq_result

  yq_result=$(yq '.permissions | (length == 0 and type == "!!map")')

  if [[ $yq_result != "true" ]]; then
    log_err "All workflows must have \"permissions: {}\" configured"
    return 1
  fi
}

check_actions_timeouts() {
  local yq_result

  yq_result=$(yq '
    [.jobs[] |
      select(
        (has("timeout-minutes") | not)
        and
        (.steps // [] |
          ([.[] | select(. | has("timeout-minutes") | not)] | length) > 0
        )
      )
    ] | length == 0'
  )

  if [[ $yq_result != "true" ]]; then
    log_err "Either all Jobs or all Steps must have \"timeout-minutes\" configured"
    return 1
  fi
}

check_actions_versions() {
  local actions_with_comments
  local check_result=0
  local yq_actions=(yq '
    (.jobs[].uses, .jobs[].steps[].uses)
      | select( . != null)
      | select(. | test("^\./") | not)
      | [., line_comment]
      | @tsv')

  IFS=$'\n' read -d '' -ra actions_with_comments < <("${yq_actions[@]}"; echo -e '\0')

  local action_with_comment action comment
  local action_with_comment_regex='^(.+)@(.+)'$'\t''(.*)$'

  for action_with_comment in "${actions_with_comments[@]}"; do
    [[ $action_with_comment =~ $action_with_comment_regex ]] || { log_err "action_with_comment: \"$action_with_comment\" is malformed"; check_result=1; continue; }

    action="${BASH_REMATCH[1]}"
    version="${BASH_REMATCH[2]}"
    comment="${BASH_REMATCH[3]}"

    check_actions_versions_ignore "$action" && continue

    [[ $version =~ ^[a-f0-9]{40}$ ]] || { log_err "action: $action - version \"$version\" is not a git commit id"; check_result=1; }
    [[ -z $comment ]] && { log_err "action: $action - version comment is absent"; check_result=1; }
  done

  (( check_result == 0 ))
}

check_actions_versions_ignore() {
  local repo=$1
  local ignore_list

  IFS=', ' read -ra ignore_list <<< "${CHECK_ACTIONS_VERSIONS_IGNORE-}"

  for ignore in "${ignore_list[@]}"; do
    [[ $repo =~ ^"$ignore"(/|$)  ]] && return 0
  done

  false
}

if [[ "${BASH_SOURCE[0]}" == "$0" ]]; then
  set -euo pipefail

  [[ ${RUNNER_DEBUG:-} == "1" ]] && set -x

  check_actions "$@"
fi

