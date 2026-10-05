# kotlinx.serialization: keep generated serializers of the save game classes.
-keepattributes *Annotation*, InnerClasses
-dontnote kotlinx.serialization.**
-keep,includedescriptorclasses class de.bornim.core.**$$serializer { *; }
-keepclassmembers class de.bornim.core.** {
    *** Companion;
}
-keepclasseswithmembers class de.bornim.core.** {
    kotlinx.serialization.KSerializer serializer(...);
}
