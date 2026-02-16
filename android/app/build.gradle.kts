plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.bmi_calcu"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // Updated to match plugin requirements

    compileOptions {
        isCoreLibraryDesugaringEnabled = true // Enable desugaring
        sourceCompatibility = JavaVersion.VERSION_1_8 // Changed to Java 8 for desugaring compatibility
        targetCompatibility = JavaVersion.VERSION_1_8 // Changed to Java 8 for desugaring compatibility
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_1_8.toString() // Changed to Java 8 for consistency
    }

    defaultConfig {
        applicationId = "com.example.bmi_calcu"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // TODO: Add your own signing config for the release build.
            // Signing with the debug keys for now, so `flutter run --release` works.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

dependencies {
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.2") // Added for desugaring
}

flutter {
    source = "../.."
}