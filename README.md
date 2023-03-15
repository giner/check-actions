# check-actions
Opinionated set of checks for GitHub Actions Workflows

## Inputs

| Option                | Required | Default             |
|-----------------------|----------|---------------------|
| check_permissions     | false    | true                |
| check_timeouts        | false    | true                |
| check_versions        | false    | true                |
| check_versions_ignore | false    | actions,aws-actions |

## Usage example

    on:
      pull_request:
        branches:
          - develop

    permissions: {}

    jobs:
      checks:
        runs-on: ubuntu-latest
        timeout-minutes: 5
        steps:
          - name: Checkout Code
            uses: actions/checkout@v3

          - name: Check Actions
            uses: giner/check-actions@2fdabb044c1d6bdd6eeffa298c4b7a3b318db1a5  # v1.0.0

## Example output

    INFO:	Checking pr.yml
    ERROR:	All workflows must have "permissions: {}" configured
    ERROR:	pr.yml - permissions check failed
    ERROR:	Either all Jobs or all Steps must have "timeout-minutes" configured
    ERROR:	pr.yml - timeouts check failed
    ERROR:	action: giner/check-actions - version "v1.0.0" is not a git commit id
    ERROR:	action: giner/check-actions - version comment is absent
    ERROR:	pr.yml - versions check failed
