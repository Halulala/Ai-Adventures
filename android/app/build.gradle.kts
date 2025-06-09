plugins {
    id("com.android.application")
    id("kotlin-android")
    // Il plugin Flutter deve essere applicato dopo Android e Kotlin
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.progetto"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973" // 🔧 NDK aggiornato per compatibilità Firebase

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        applicationId = "com.example.progetto"
        minSdk = 23 // 🔧 Minimo SDK richiesto da firebase_auth
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            // Usa la configurazione di debug temporaneamente per il rilascio
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}
