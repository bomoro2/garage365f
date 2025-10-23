plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.garage365"
    compileSdk = 36

    defaultConfig {
        applicationId = "com.example.garage365"
        minSdk = flutter.minSdkVersion            // <-- clave para CameraX / mobile_scanner
        targetSdk = 36
        versionCode = 1
        versionName = "1.0"
    }

    // Si te vuelve a advertir por NDK, podés fijarlo explícito:
    // ndkVersion = "27.0.12077973"
    // (si no, dejá la línea de abajo con la de Flutter)
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    buildTypes {
        release {
            // Firmado de debug para poder instalar rápido en release
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
