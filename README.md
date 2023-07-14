# Adams-Rbase

Dermatlas Docker image for R base (4.2.2) and packages

## Using the container

The container can be accessed via the repo [packages](repo-package).

### Docker

Change `develop` as appropriate.  If private you will need to perform relevant authentication.

```
docker pull ghcr.io/cynapse-ccri/adams-rbase:develop
docker run --rm -ti ghcr.io/cynapse-ccri/adams-rbase:develop
```

You will need to mount data appropriately via the docker option `-v`.  Recommended approach:

```
docker run --rm -ti \
    -v /full/path/inputs:/home/rbase/inputs:ro \
    -v /full/path/outputs:/home/rbase/outputs:rw \
    ghcr.io/cynapse-ccri/adams-rbase:develop
```

Once the container is running, open an R session.

```
R
```

Then restore the renv environment.

```
renv::restore()
```

You will need to agree to to the activation of the environment and loading of the packages (by typing "y").
This will load the packages from the cache.

### Singularity

You will need to create an environment file, `singularity.env`, also included in repo as a file:

```
OPT="/opt/rbase"
PATH="/opt/rbase/bin:$PATH"
RENV_PATHS_ROOT="/opt/rbase"
```

Change `develop` as appropriate.  If private you will need to perform relevant authentication.

```
# creates adams-rbase_develop.sif
singularity pull docker://ghcr.io/cynapse-ccri/adams-rbase:develop
# provides interactive shell
singularity shell --env-file singularity.env -H /home/rbase --no-home --writable-tmpfs --cleanenv adams-rbase_develop.sif
```

You will need to mount data appropriately via the singularity bind option `--bind`.  Recommended approach:

```
# Directly executes R when starting (exec vs shell)
singularity exec --env-file singularity.env -H /home/rbase --no-home --writable-tmpfs --cleanenv \
    --bind /full/path/inputs:/home/rbase/inputs:ro \
    --bind /full/path/outputs:/home/rbase/outputs:rw \
    adams-rbase_develop.sif R
```

Next set two parameters to ensure renv restores from cache and then restore the renv environment.

```
renv::settings$use.cache(TRUE)
renv::restore()
```

You will need to agree to to the activation of the environment and loading of the packages (by typing "y").
This will load the packages from the cache.

### Extending the images

The extension_example folder contains a Dockerfile with an example of expanding the image to also include the package caret. This can be build using the command:

```
docker build . -f extension_example/Dockerfile -t adams-rbase:extended
```

It takes a few minutes to run whilst it downloads and installs the caret and its dependencies.

This images can be run like above, using the the tag "adams-rbase:extended" just assigned to it.

```
docker run --rm -ti \
    -v /full/path/inputs:/home/rbase/inputs:ro \
    -v /full/path/outputs:/home/rbase/outputs:rw \
    adams-rbase:extended
```

## Development

This repository has been configured to utilise the VSCode + GitHub Codespaces integration.  This means no setup is required.
If developing in a different environment, please ensure you install and activate pre-commit to prevent build errors in
the GitHub Actions workflows.

### GitHub Actions

GitHub actions are active on this repository.  They will execute automatically for:

- Pushes to `develop` & `main`
- Tag creations patterns `v?[0-9]+.[0-9]+.[0-9]+`, `v?[0-9]+.[0-9]+`
- Pull requests against `develop` & `main`
  Docker builds within actions have access to a persistent build cache (7 days) so rebuilds are generally rapid.

### Secrets for Actions

Dockerhub account credentials are required to prevent image pulls hitting rate limits.

- Ensure readonly privileges on service account, variables to set are:
  - `DOCKER_HUB_USERNAME`
  - `DOCKER_HUB_ACCESS_TOKEN`

### GitHub Container Registry

Actions automatically register the container image in the GitHub container registry.  You are able to set **containers public**
while keeping **code private**.  Be aware that the `README.md` is common to the code and container registry.

### Docker image information

- Final user is `rbase`

### Branching

The repository has been setup with an expectation that good branching practice is used.

- Features
  - Branch from `develop`
  - Merged to `develop`
- Hotfixes
  - Branch from `main`
  - Merged to `main`, tagged on `main` and then `main` merged into `develop`.

The codespace is configured with hubflow git extensions to simplify this process.  If you are unfamiliar with this please see [here](hubflow).
If you start the codespace with a branch other than develop you may need to checkout the `develop` branch and switch back to your working branch to use hubflow commands such as `feature finish` or `hotfix finish`.
