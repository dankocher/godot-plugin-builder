# Godot Plugin Builder

This project is designed to simplify the process of building custom Godot engine templates and plugins for Android and
iOS platforms using **SCons**. The guide below details the steps required to:

1. Compile a custom Godot template for Android and iOS (in both release and debug modes).
2. Compile the **FirebasePlugin**.
3. Compile the **InAppStore Purchases Plugin**.

---

## Table of Contents

1. [Requirements](#requirements)
2. [Setting Up the Environment](#setting-up-the-environment)
3. [Steps to Compile Custom Templates](#steps-to-compile-custom-templates)
4. [Steps to Compile Plugins](#steps-to-compile-plugins)

---

## Requirements

To successfully build the templates and plugins, ensure the following tools and dependencies are installed:

- **Python** (required to run SCons)
- **SCons** (Build tool for Godot)
- **Android SDK/NDK** (required for Android builds)
- **Xcode** (required for iOS builds)
- **Godot Engine source code** (matching your target version)
- Additional build tools or dependencies:
    - Firebase-related SDKs for the Firebase plugin.
    - Payment SDKs for the InAppStore Purchases plugin.

---

## Setting Up the Environment

1. Clone the Godot source code:
   ```bash
   git clone https://github.com/godotengine/godot.git
   cd godot
   ```

2. Install **SCons**:
   ```bash
   pip install scons
   ```

3. Configure the build environment:
    - For **Android**: Set up your Android paths (`ANDROID_HOME`, `ANDROID_NDK_ROOT`, etc.).
    - For **iOS**: Install Xcode and ensure command-line tools are set up (`xcode-select`).

---

## Steps to Compile Custom Templates

Follow these steps to compile a customized template for Godot:


https://docs.godotengine.org/en/stable/contributing/development/compiling/optimizing_for_size.html

https://godot-build-options-generator.github.io/

### Android (Release and Debug)

1. Navigate to the Godot source directory.
2. Run the following commands to build the Android templates:

   **Release Build:**
   ```bash
   scons platform=android target=release android_arch=armv7
   scons platform=android target=release android_arch=arm64v8
   ```

   **Debug Build:**
   ```bash
   scons platform=android target=debug android_arch=armv7
   scons platform=android target=debug android_arch=arm64v8
   ```

3. The output files will be available in the `bin` directory:
    - `godot.android.opt.armv7.apk` (Release for ARMv7)
    - `godot.android.opt.arm64.apk` (Release for ARM64)
    - `godot.android.debug.armv7.apk` (Debug for ARMv7)
    - `godot.android.debug.arm64.apk` (Debug for ARM64)

### iOS (Release and Debug)

1. From the Godot source directory, run the following commands:

   **Release Build:**
   ```bash
   scons platform=ios target=release
   ```

   **Debug Build:**
   ```bash
   scons platform=ios target=debug
   ```

2. The output files will be located in the `bin` directory:
    - `godot.ios.opt` (Release version).
    - `godot.ios.debug` (Debug version).

---

## Steps to Compile Plugins

This project supports the building of custom plugins, such as FirebasePlugin and InAppStore Purchases Plugin.

### FirebasePlugin

1. Clone the **FirebasePlugin** repository into the desired location.
   ```bash
   git clone https://github.com/example/firebase-plugin.git
   cd firebase-plugin
   ```

2. Modify the `config.py` or any required files to link Firebase SDKs and required keys.

3. Run **SCons** to build the plugin:

   **For Android:**
   ```bash
   scons platform=android
   ```

   **For iOS:**
   ```bash
   scons platform=ios
   ```

4. The plugin output can be found in the `bin` directory.

### InAppStore Purchases Plugin

1. Clone the **InAppStore Purchases Plugin** repository:
   ```bash
   git clone https://github.com/example/inappstore-plugin.git
   cd inappstore-plugin
   ```

2. Configure the build settings to link the payment SDKs (specific files may vary by implementation).

3. Run **SCons** to build the plugin:

   **For Android:**
   ```bash
   scons platform=android
   ```

   **For iOS:**
   ```bash
   scons platform=ios
   ```

4. The plugin output will be available in the `bin` directory.

---

## Notes

- Ensure all system dependencies are properly configured before initiating any builds.
- For additional customization or troubleshooting, refer to the official
  Godot [documentation](https://godotengine.org/documentation) and community forums.
- For platform-specific issues, consult the Android or iOS SDK guides.

---
