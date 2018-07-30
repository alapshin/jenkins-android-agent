FROM jenkinsci/slave:latest as jenkins-agent

ARG PACKAGES="git make wget unzip"
ARG ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-3859397.zip"
ARG ANDROID_PACKAGES="tools platform-tools build-tools;28.0.1 platforms;android-27 extras;google;m2repository extras;android;m2repository ndk-bundle"

# Become root
USER root

# Install required packages
RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests ${PACKAGES} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables for Android SDK
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_NDK_HOME ${ANDROID_HOME}/ndk-bundle
# Add Android SDK binaries to PATH
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDORID_HOME}/platform-tools

# Create directory for Android SDK
# Download and install Android SDK and its components
RUN mkdir -p ${ANDROID_HOME} \
    && cd ${ANDROID_HOME} \
    && wget --quiet --output-document=android-tools.zip ${ANDROID_SDK_URL} \
    && unzip android-tools.zip \
    && rm --f android-tools.zip \
    && yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses \
    && ${ANDROID_HOME}/tools/bin/sdkmanager --verbose ${ANDROID_PACKAGES} \
    && chown --recursive jenkins:jenkins ${ANDROID_HOME}

# Drop to jenkins user
USER jenkins

# Declare volume for Android SDK
VOLUME ${ANDROID_HOME}
