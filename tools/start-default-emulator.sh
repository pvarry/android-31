#!/bin/bash

# Originally written by Ralf Kistner <ralf@embarkmobile.com>, but placed in the public domain

echo "Starting default emulator"
$ANDROID_HOME/emulator/emulator -avd default_avd -no-window -no-audio &

