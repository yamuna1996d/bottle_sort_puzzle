import java.util.Properties
import java.io.FileInputStream

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.bottlesort.bottle_sort_puzzle"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.bottlesort.bottle_sort_puzzle"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    signingConfigs {
        create("release") {
            val propFile = file("SIGNING_CONFIG.properties")
            if (propFile.canRead()) {
                val props = Properties().apply { load(FileInputStream(propFile)) }
                if (props.containsKey("STORE_FILE") && props.containsKey("KEY_STORE_PASSWORD")
                    && props.containsKey("KEY_ALIAS") && props.containsKey("KEY_PASSWORD")) {
                    storeFile = file(props["STORE_FILE"] as String)
                    storePassword = props["KEY_STORE_PASSWORD"] as String
                    keyAlias = props["KEY_ALIAS"] as String
                    keyPassword = props["KEY_PASSWORD"] as String
                } else {
                    println("SIGNING_CONFIG.properties found but some entries are missing")
                }
            } else {
                println("SIGNING_CONFIG.properties not found")
            }
        }
    }

    buildTypes {
        release {
            val propFile = file("SIGNING_CONFIG.properties")
            signingConfig = if (propFile.canRead()) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android.txt"), "proguard-rules.pro")
        }
    }
}

flutter {
    source = "../.."
}
