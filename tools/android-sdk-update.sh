#!/bin/bash

mkdir -p /opt/android-sdk-linux/bin/
cp /opt/tools/android-env.sh /opt/android-sdk-linux/bin/
source /opt/android-sdk-linux/bin/android-env.sh

built_in_sdk=1


echo $#

echo $1

if [ $# -ge 0 ] && [ "$1" == "lazy-dl" ]
then
    echo "Using Lazy Download Flavour"
    built_in_sdk=0
elif [ $# -ge 0 ] && [ "$1" == "built-in" ]
then
    echo "Using Built-In SDK Flavour"
    built_in_sdk=1
else
    echo "Please use either built-in or lazy-dl as parameter"
    exit 1
fi

cd ${ANDROID_SDK_ROOT}
echo "Set ANDROID_SDK_ROOT to ${ANDROID_SDK_ROOT}"

if [ -f commandlinetools-linux.zip ]
then
  echo "SDK Tools already bootstrapped. Skipping initial setup"
else
  echo "Bootstrapping SDK-Tools"
  wget -q https://dl.google.com/android/repository/commandlinetools-linux-7583922_latest.zip -O commandlinetools-linux.zip

  unzip commandlinetools-linux.zip -d commandlinetools-linux
  mkdir cmdline-tools
  mkdir cmdline-tools/tools-tmp

  mv commandlinetools-linux/cmdline-tools/* cmdline-tools/tools-tmp
  rm -rf commandlinetools-linux
  rm commandlinetools-linux.zip
fi

echo "Make sure repositories.cfg exists"
mkdir -p ~/.android/
touch ~/.android/repositories.cfg

echo "Copying Licences"
cp -rv /opt/licenses ${ANDROID_SDK_ROOT}/licenses

echo "Copying Tools"
mkdir -p ${ANDROID_SDK_ROOT}/bin
cp -v /opt/tools/*.sh ${ANDROID_SDK_ROOT}/bin

echo "Accepting Licenses"
yes | /opt/android-sdk-linux/cmdline-tools/tools-tmp/bin/sdkmanager --sdk_root=${ANDROID_SDK_ROOT} --licenses
