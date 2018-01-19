FROM alapshin/android-build-env:latest as android-sdk
FROM jenkinsci/slave:latest as jenkins-agent

# Set Android SDK path
ENV ANDROID_HOME "/opt/android-sdk"

VOLUME $ANDROID_HOME
# Copy preconfigured Android SDK
COPY --from=android-sdk --chown=jenkins /opt/android-sdk $ANDROID_HOME

# Add Android SDK binaries to PATH
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDORID_HOME}/platform-tools
