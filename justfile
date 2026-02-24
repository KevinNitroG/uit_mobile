default: build-debug adb-install

build-debug:
    flutter build apk --debug

adb-install:
    adb install -r build/app/outputs/apk/debug/app-debug.apk
