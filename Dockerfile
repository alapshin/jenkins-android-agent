FROM jenkinsci/slave:3.27-1-jdk11

ARG PACKAGES="git make wget unzip"
ARG ANDROID_SDK_URL="https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip"
ARG ANDROID_PACKAGES="tools platform-tools build-tools;28.0.3 platforms;android-28 extras;google;m2repository extras;android;m2repository ndk-bundle"

# Become root
USER root

# Install required packages
RUN apt-get update \
    && apt-get install --yes --no-install-recommends --no-install-suggests ${PACKAGES} \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Download JAXB libraries used by sdkmanager because they are not available out of the box in JDK 11
ENV JAXB_PATH /opt/jaxb
RUN mkdir -p ${JAXB_PATH} \ 
    && wget --quiet --directory-prefix=${JAXB_PATH} \ 
    https://repo1.maven.org/maven2/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar \
    https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-jxc/2.3.2/jaxb-jxc-2.3.2.jar \
    https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-impl/2.3.2/jaxb-impl-2.3.2.jar \
    https://repo1.maven.org/maven2/com/sun/xml/bind/jaxb-core/2.3.0.1/jaxb-core-2.3.0.1.jar \
    https://repo1.maven.org/maven2/javax/activation/activation/1.1.1/activation-1.1.1.jar

# Set environment variables for Android SDK
ENV ANDROID_HOME /opt/android-sdk
ENV ANDROID_NDK_HOME ${ANDROID_HOME}/ndk-bundle
# Add Android SDK binaries to PATH
ENV PATH ${PATH}:${ANDROID_HOME}/tools:${ANDROID_HOME}/tools/bin:${ANDORID_HOME}/platform-tools

# Create directory for Android SDK
# Download and install Android SDK and its components
RUN mkdir -p ${ANDROID_HOME} \
    && wget --quiet --output-document=${ANDROID_HOME}/sdk-tools.zip ${ANDROID_SDK_URL} \
    && unzip -d ${ANDROID_HOME} ${ANDROID_HOME}/sdk-tools.zip \
    && rm --force ${ANDROID_HOME}/sdk-tools.zip \
    # Add JAXB libraries to sdkmanager classpath
    && sed -i 's/CLASSPATH=$.*/&:${JAXB_PATH}\/jaxb-impl-2.3.2.jar:${JAXB_PATH}\/jaxb-api-2.3.1.jar:${JAXB_PATH}\/jaxb-jxc-2.3.2.jar:${JAXB_PATH}\/jaxb-core-2.3.0.1.jar:${JAXB_PATH}\/activation-1.1.1.jar/' ${ANDROID_HOME}/tools/bin/sdkmanager \
    # Accept all licenses
    && yes | ${ANDROID_HOME}/tools/bin/sdkmanager --licenses \
    # Install specified packages
    && ${ANDROID_HOME}/tools/bin/sdkmanager --verbose ${ANDROID_PACKAGES} \
    # Make jenkins user an onwer of SDK directory
    && chown --recursive jenkins:jenkins ${ANDROID_HOME}

# Drop to jenkins user
USER jenkins

# Declare volume for Android SDK
VOLUME ${ANDROID_HOME}
