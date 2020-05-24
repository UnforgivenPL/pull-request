# pull-request
GitHub action for making or editing pull requests.

# Inputs
## `source`
**Required.** Name of an existing source branch.
## `target`
Name of an existing target branch (into which contents of the source branch are pulled). Defaults to repository's default branch.
## `repository`
**Required.** Path to repository to make PR in.
## `token`
**Required.** Auth token with enough privileges to create a PR in a given repository.
## `pr-title`
Title of the PR. Required if there is no existing, open PR between the two branches.
## `pr-body`
Body of the PR.
## `pr-draft`
Whether or not this is a draft PR. Defaults to `false`.
## `pr-assignees`
Comma-separated logins of users assigned to the PR.
## `pr-labels`
Comma-separated labels of the PR.
## `pr-milestone`
Number of the milestone the PR should be added to.
## `overwrite-strategy`
Either `success`, `change` or `fail` (default); describes what to do when an open PR already exists.

# Outputs
None. PR will be created or updated, depending on options. If anything fails, please check the logs for a detailed message.

# Contributing
Missing a feature? Found a bug? Please create an issue. Thank you!

# Licensing
Code distributed "as is", without liabilities or warranties. Please consult `LICENSE` for details. Written by Miki Olsz. (c) 2020 Unforgiven.pl.
