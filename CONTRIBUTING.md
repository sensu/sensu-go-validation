
# Docker images

Docker images are built on every pull request and every push. Those builds are for testing the build still works.
Commits to `main` branch will build `latest` tag and publish that to Docker Hub.
Git tags will build an image with version tag, so git tag `1.0.0` will produce the image `sensu/sensu-go-validation:1.0.0`.
Those git tagged images are also pushed to Docker Hub.
