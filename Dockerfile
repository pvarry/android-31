FROM ubuntu:18.04

ENV DEBIAN_FRONTEND noninteractive

ENV ANDROID_HOME      /opt/android-sdk-linux
ENV ANDROID_SDK_HOME  ${ANDROID_HOME}
ENV ANDROID_SDK_ROOT  ${ANDROID_HOME}
ENV ANDROID_SDK       ${ANDROID_HOME}

ENV PATH "${PATH}:${ANDROID_HOME}/cmdline-tools/latest/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/tools/bin"
ENV PATH "${PATH}:${ANDROID_HOME}/build-tools/31.0.0"
ENV PATH "${PATH}:${ANDROID_HOME}/platform-tools"
ENV PATH "${PATH}:${ANDROID_HOME}/emulator"
ENV PATH "${PATH}:${ANDROID_HOME}/bin"

RUN dpkg --add-architecture i386 && \
    apt-get update -yqq && \
    apt-get install -y curl expect git libc6:i386 libgcc1:i386 libncurses5:i386 libstdc++6:i386 zlib1g:i386 openjdk-11-jdk wget unzip vim && \
    apt-get clean

RUN groupadd android && useradd -d /opt/android-sdk-linux -g android android

COPY tools /opt/tools
COPY licenses /opt/licenses

WORKDIR /opt/android-sdk-linux

RUN /opt/tools/entrypoint.sh built-in

RUN /opt/android-sdk-linux/cmdline-tools/tools-tmp/bin/sdkmanager "cmdline-tools;latest"
RUN rm -rf /opt/android-sdk-linux/cmdline-tools/tools-tmp
RUN sdkmanager "build-tools;31.0.0"
RUN sdkmanager "platform-tools"
RUN sdkmanager "platforms;android-31"
RUN sdkmanager "system-images;android-31;google_apis;x86_64"
RUN sdkmanager "emulator"
RUN sdkmanager --update

# Disable Gradle daemon, since we are running on a CI server.
RUN mkdir ${HOME}/.gradle \
  && echo "org.gradle.daemon=false" > ${HOME}/.gradle/gradle.properties

RUN echo y | sdkmanager "system-images;android-31;google_apis;x86_64" \
  && echo "no" | avdmanager create avd -n default_avd --abi google_apis/x86_64 -k "system-images;android-31;google_apis;x86_64"

CMD /opt/tools/entrypoint.sh built-in
