{
  description = "Flutter Development Environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (system: let
      pkgs = import nixpkgs {
        inherit system;
        config = {
          android_sdk.accept_license = true;
          allowUnfree = true;
        };
      };

      androidComposition = pkgs.androidenv.composeAndroidPackages {
        cmdLineToolsVersion = "latest";
        toolsVersion = "26.1.1";
        platformToolsVersion = "35.0.2";
        buildToolsVersions = ["36.0.0" "35.0.0"];
        platformVersions = ["36" "34"];
        cmakeVersions = ["3.22.1"];
        includeNDK = true;
        ndkVersions = ["27.0.12077973"];
        includeEmulator = false;
        includeSystemImages = false;
        useGoogleAPIs = true;
        extraLicenses = [
          ".android-sdk-license"
          ".android-sdk-preview-license"
          "google-gdk-license"
        ];
      };

      androidSdk = androidComposition.androidsdk;
    in {
      devShell = pkgs.mkShell rec {
        buildInputs = with pkgs; [
          flutter
          androidSdk
          jdk17
          pkg-config
          gradle
        ];

        shellHook = ''
          echo ""
            echo "Setting up Flutter development environment..."

            print_status() { echo -e "\033[32m✓\033[0m $1"; }
            print_error() { echo -e "\033[31m✗\033[0m $1"; }
            print_info() { echo -e "\033[34mℹ\033[0m $1"; }

            if [ ! -d "$HOME/.android-sdk" ]; then
              print_info "Creating writable Android SDK directory..."
              mkdir -p "$HOME/.android-sdk"
              if cp -r ${androidSdk}/libexec/.android-sdk/* "$HOME/.android-sdk/" 2>/dev/null; then
                print_status "Android SDK copied successfully"
              else
                print_error "Failed to copy Android SDK files"
                exit 1
              fi
              chmod -R 755 "$HOME/.android-sdk"
              print_status "Permissions set for Android SDK"
            else
              print_status "Android SDK directory already exists"
            fi

            export PATH="$PATH:$HOME/.android-sdk/platform-tools"
            export PATH="$PATH:$HOME/.android-sdk/cmdline-tools/latest/bin"
            export PATH="$PATH:$HOME/.pub-cache/bin"
            print_status "PATH variables updated"

            if command -v flutter &> /dev/null; then
              flutter config --.android-sdk "$HOME/.android-sdk" &>/dev/null
              print_status "Flutter configured to use local Android SDK"
            fi

            # Create cmdline-tools/latest symlink if missing
            if [ ! -L "$HOME/.android-sdk/cmdline-tools/latest" ]; then
              if [ -d "$HOME/.android-sdk/cmdline-tools/11.0" ]; then
                ln -sfn "$HOME/.android-sdk/cmdline-tools/11.0" "$HOME/.android-sdk/cmdline-tools/latest"
                print_status "Created symlink cmdline-tools/latest -> 11.0"
              else
                print_error "cmdline-tools/11.0 directory missing, cannot create 'latest' symlink"
              fi
            else
              print_status "cmdline-tools/latest symlink already exists"
            fi

            print_info "Accepting Android SDK licenses..."
            if [ -x "$HOME/.android-sdk/cmdline-tools/latest/bin/sdkmanager" ]; then
              mkdir -p "$HOME/.android-sdk/licenses"
              yes | "$HOME/.android-sdk/cmdline-tools/latest/bin/sdkmanager" --licenses >/dev/null 2>&1 || {
                print_info "Fallback: writing license files manually..."
                echo "24333f8a63b6825ea9c5514f83c2829b004d1fee" > "$HOME/.android-sdk/licenses/.android-sdk-license"
                echo "84831b9409646a918e30573bab4c9c91346d8abd" > "$HOME/.android-sdk/licenses/.android-sdk-preview-license"
                echo "d975f751698a77b662f1254ddbeed3901e976f5a" > "$HOME/.android-sdk/licenses/google-gdk-license"
                echo "601085b94cd77f0b54ff86406957099ebe79c4d6" > "$HOME/.android-sdk/licenses/intel-android-extra-license"
                print_status "License files created manually"
              }
              print_status "Android SDK licenses accepted"
            else
              print_error "sdkmanager not found or not executable"
            fi

            print_info "Verifying setup..."
            if [ -d "$HOME/.android-sdk" ] && [ -d "$HOME/.android-sdk/licenses" ]; then
              print_status "Android SDK setup complete"
            else
              print_error "Android SDK setup incomplete"
            fi

            echo ""
            echo "Flutter Development Environment Ready!"
            echo " - Android SDK: $ANDROID_HOME"
            echo " - NDK: $ANDROID_NDK_ROOT"
            echo " - CMake: $CMAKE_ROOT"
            echo " - Java: $JAVA_HOME"
            echo ""
        '';
        ANDROID_SDK_ROOT = "$HOME/.android-sdk";
        ANDROID_HOME = "$HOME/.android-sdk";
        ANDROID_NDK_ROOT = "$HOME/.android-sdk/ndk/27.0.12077973";
        JAVA_HOME = "${pkgs.jdk17}";
        CMAKE_ROOT = "$HOME/.android-sdk/cmake/3.22.1";

        GRADLE_OPTS = "-Dorg.gradle.project.android.aapt2FromMavenOverride=$HOME/.android-sdk/build-tools/34.0.0/aapt2";
      };
    });
  flake.templates.default = {
    path = ./.;
    description = "Rust Project template with Nix DevShell";
  };
}
