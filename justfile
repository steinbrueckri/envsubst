image := "envsubst-test:latest"

default:
    @just --list

build:
    docker build -t {{image}} .

test: build
    docker run --rm -i hadolint/hadolint < Dockerfile
    bats tests/envsubst.bats
    docker run --rm \
        -v /var/run/docker.sock:/var/run/docker.sock \
        -v "$(pwd)/tests/structure_test.yaml:/tests/structure_test.yaml:ro" \
        gcr.io/gcp-runtimes/container-structure-test:latest \
        test --image {{image}} --config /tests/structure_test.yaml
