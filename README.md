# check-actions
Opinionated set of checks for GitHub Actions Workflows

## Inputs

| Option                | Required | Default             | Description                                                                                          | Notes                                                                                                                                                                                                                                                                                     |
|-----------------------|----------|---------------------|------------------------------------------------------------------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| check_permissions     | false    | true                | Check whether GITHUB_TOKEN permissions are set to empty on Workflow level                            | Read more on [security guides](https://docs.github.com/en/actions/security-guides/automatic-token-authentication#permissions-for-the-github_token) and [using jobs](https://docs.github.com/en/actions/using-jobs/assigning-permissions-to-jobs)                                          |
| check_timeouts        | false    | true                | Check whether all jobs or steps have timeouts configured                                             | Read more about [job timeouts](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idtimeout-minutes) and [step timeouts](https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions#jobsjob_idstepstimeout-minutes) |
| check_versions        | false    | true                | Check whether versions for all actions are pinned and comments exist (e.g. myaction@23fd21f  # v1.2) | Read more about [3rd-party actions](https://docs.github.com/en/actions/security-guides/security-hardening-for-github-actions#using-third-party-actions)                                                                                                                                   |
| check_versions_ignore | false    | actions,aws-actions | Do not check versions for these organizations and repositories (comma or space separated)            |                                                                                                                                                                                                                                                                                           |

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
