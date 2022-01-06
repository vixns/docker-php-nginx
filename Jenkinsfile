#!/usr/bin/env groovy

node {
  checkout scm
  withCredentials([
    usernamePassword(
      credentialsId: 'dockerhub',
      usernameVariable: 'DOCKER_HUB_USER',
      passwordVariable: 'DOCKER_HUB_PASSWORD'),
    ]) {

    stage("Docker login") {
        sh """
        ## Login to Docker Repo ##
        docker login -u $DOCKER_HUB_USER -p $DOCKER_HUB_PASSWORD
        """
    }

    // Note: qemu is responsible for building images that are not supported by host
    stage("Register QEMU emulators") {
        sh """
        docker run --rm --privileged docker/binfmt:820fdd95a9972a5308930a2bdfb8573dd4447ad3
        cat /proc/sys/fs/binfmt_misc/qemu-aarch64
        """
    }

    // Create a buildx builder container to do the multi-architectural builds
    stage("Create Buildx Builder") {
        sh """
        ## Create buildx builder
        docker buildx create --name mbuilder
        docker buildx use mbuilder
        docker buildx inspect --bootstrap

        ## Sanity check step
        docker buildx ls
        """
    }

    // Now we build using buildx
    stage("Build multi-arch image") {
        sh """
        docker buildx build --platform linux/amd64,linux/arm64 --push -t vixns/php-nginx:$BRANCH_NAME .
        """
    }

    // Need to clean up
    stage("Destroy buildx builder") {
        sh """
        docker buildx use default
        docker buildx rm mbuilder

        ## Sanity check step
        docker buildx ls
        """
    }
  }
}
