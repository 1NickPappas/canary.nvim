plugins {
    kotlin("jvm") version "1.9.0"
    application
}

repositories {
    mavenCentral()
}

dependencies {
    implementation("com.google.guava:guava:31.0-jre")
    implementation("org.jetbrains.kotlinx:kotlinx-coroutines-core:1.7.3")
    testImplementation("junit:junit:4.13.2")
    testImplementation("org.assertj:assertj-core:3.24.2")
}

application {
    mainClass.set("com.example.MainKt")
}
