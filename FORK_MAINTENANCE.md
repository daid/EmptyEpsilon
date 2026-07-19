# Fork Maintenance

This fork uses two long-lived branches:

- `master` is a pristine mirror of official EmptyEpsilon from `upstream/master`.
- `gwaland-main` is the version to build, run, and maintain with local custom changes.

New custom features should branch from `gwaland-main`, not `master`. Upstream changes should be merged into `gwaland-main` with merge commits so the custom branch history remains intact.

Do not rebase `gwaland-main` after it has been published. Rebasing would rewrite published history and make collaboration and future maintenance harder.

The word "backport" is not quite right for this workflow. The maintained fork is merging or forward-porting upstream changes from official EmptyEpsilon into `gwaland-main`.

## Remotes

- `origin`: `gwaland/EmptyEpsilon`
- `upstream`: `daid/EmptyEpsilon`

## Direct Upstream Update Workflow

Use this when updating the maintained fork directly:

```bash
git fetch upstream
git switch master
git merge --ff-only upstream/master
git push origin master

git switch gwaland-main
git merge --no-ff master
git push origin gwaland-main
```

The `--ff-only` merge keeps `master` as a clean mirror of official EmptyEpsilon. The `--no-ff` merge into `gwaland-main` preserves an explicit merge point for upstream updates.

## Pull-Request-Based Update Workflow

Use this when you want to review upstream changes in a pull request before merging them into `gwaland-main`:

```bash
git fetch upstream

git switch master
git merge --ff-only upstream/master
git push origin master

git switch gwaland-main
git switch -c sync/upstream-YYYY-MM-DD
git merge --no-ff master
```

After resolving any conflicts and validating the build, push the `sync/upstream-YYYY-MM-DD` branch and open a pull request into `gwaland-main`.
