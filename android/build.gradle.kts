plugins {
    id("com.android.application")
    kotlin("android")
}

android {
    compileSdk = 36  // Defina a versão do SDK que você está utilizando

    defaultConfig {
        applicationId = "com.example.seuprojeto"  // Substitua pelo seu ID de pacote
        minSdk = 21  // Defina a versão mínima do SDK suportada
        targetSdk = 35  // Defina a versão do SDK para o alvo
        versionCode = 1
        versionName = "1.0"
    }

    buildTypes {
        release {
            minifyEnabled = false
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
        }
    }

    // Aqui você define a versão do NDK para a versão que está instalada no seu sistema
    ndkVersion = "29.0.13113456"  // Altere para a versão do NDK instalada no seu sistema
}

dependencies {
    implementation("org.jetbrains.kotlin:kotlin-stdlib-jdk7:$kotlin_version")
    implementation("androidx.core:core-ktx:1.7.0")
    implementation("androidx.appcompat:appcompat:1.3.1")
    implementation("com.google.android.material:material:1.4.0")
    implementation("androidx.constraintlayout:constraintlayout:2.1.1")
    // Adicione outras dependências conforme necessário
}
