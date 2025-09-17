import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.syusyumarion.busanbusnyamyam"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_11.toString()
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.syusyumarion.busanbusnyamyam"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // read from local.properties (gitignored) or env
        val lp = Properties()
        val lpf = rootProject.file("local.properties")
        if (lpf.exists()) {
            lp.load(FileInputStream(lpf))
        }
        val mapsKey = lp.getProperty("MAPS_ANDROID_KEY") ?: System.getenv("MAPS_ANDROID_KEY") ?: ""
        println("🗺️ MAPS_ANDROID_KEY loaded: ${mapsKey.take(10)}...")
        manifestPlaceholders["MAPS_ANDROID_KEY"] = mapsKey
    }

    signingConfigs {
        create("release") {
            keyAlias = "release-key"
            keyPassword = "busanbusnyamyam"
            storeFile = file("app-release-key.keystore")
            storePassword = "busanbusnyamyam"
        }
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("release")
            isMinifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
