# Jenkins Android agent

Docker image for Jenkins build agent containing Android SDK.

## Build
To build image run
```
docker build -t username/jenkins-android-agent .
```

Take into account that `Dockerfile` uses [multi-stage build][2] to copy
preinstalled Android SDK from [android-build-env][3]. Multi-stage builds require
Docker 17.05 or later.

## Usage
Image is supposed to be used with Jenkins' [docker-plugin][1]. This plugin
supports three different methods to launch docker containers but this image is
should be launched with `Launch attached` method.

### Volumes used by image
Image specifies a number of volumes
1. `android_sdk:/opt/android-sdk` - Android SDK directory. There Android Gradle
plugin will download missing SDK dependencies. To avoid downloading dependencies
every time this directory could be placed into volume.
2. `jenkins_agent_home:/home/jenkins` - Jenkins agent home  directory. There
Jenkins will create `workspace` directory used for cloning and building the
project. To avoid cloning project on every build this could be placed into volume.
3. `jenkins_agent_cache:/home/jenkins/.jenkins` - Jenkins agent JAR cache.
4. `jenkins_agent_workdir:/home/jenkins/agent` - Jenkins agent working directory.


[1]: https://plugins.jenkins.io/docker-plugin
[2]: https://docs.docker.com/develop/develop-images/multistage-build/
[3]: https://github.com/alapshin/android-build-env
