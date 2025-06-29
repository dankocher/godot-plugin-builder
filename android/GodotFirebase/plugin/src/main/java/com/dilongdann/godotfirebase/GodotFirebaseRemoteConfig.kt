package com.dilongdann.godotfirebase

import android.util.Log
import com.google.firebase.remoteconfig.FirebaseRemoteConfig
import com.google.firebase.remoteconfig.FirebaseRemoteConfigSettings
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class GodotFirebaseRemoteConfig(godot: Godot) : GodotPlugin(godot) {

    companion object {
        private const val TAG = "FirebaseRemoteConfig"
        private const val MINIMUM_FETCH_INTERVAL: Long = 3600 // En segundos (1 hora)
    }

    private val remoteConfig: FirebaseRemoteConfig by lazy {
        FirebaseRemoteConfig.getInstance()
    }

    init {
        // Configurar Remote Config settings
        val configSettings = FirebaseRemoteConfigSettings.Builder()
            .setMinimumFetchIntervalInSeconds(MINIMUM_FETCH_INTERVAL)
            .build()
//        val remoteConfig: FirebaseRemoteConfig = Firebase.remoteConfig
//        val configSettings = remoteConfigSettings {
//            minimumFetchIntervalInSeconds = 3600
//        }
        remoteConfig.setConfigSettingsAsync(configSettings)
        Log.v(TAG, "Firebase Remote Config initialized with fetch interval: $MINIMUM_FETCH_INTERVAL seconds")
    }

    override fun getPluginName(): String {
        return "GodotFirebaseRemoteConfig"
    }

    override fun getPluginSignals(): MutableSet<SignalInfo> {
        return mutableSetOf(
            SignalInfo("remote_config_updated"),
            SignalInfo("remote_config_fetch_failed", String::class.java)
        )
    }

    /**
     * Método para obtener nuevos valores de configuración remota.
     */
    @UsedByGodot
    fun fetch_remote_config() {
        remoteConfig.fetchAndActivate()
            .addOnCompleteListener { task ->
                if (task.isSuccessful) {
                    val updated = task.result
                    Log.i(TAG, "Remote Config actualizado: $updated")
                    emitSignal("remote_config_updated") // Emitir señal de éxito
                } else {
                    val errorMessage = task.exception?.message ?: "Unknown error"
                    Log.e(TAG, "Error al obtener Remote Config: $errorMessage")
                    emitSignal("remote_config_fetch_failed", errorMessage) // Emitir señal de error
                }
            }
    }

    /**
     * Método para obtener el valor de configuración remota para una clave específica.
     */
    @UsedByGodot
    fun get_remote_config_value(key: String): String? {
//        val value = remoteConfig.getValue(key)
        val value = remoteConfig.getString(key)

        return value

//        println(remoteConfig)

//        return when {
//            // JSON - Manejado como String para que sea compatible con Godot
//            value.asString().startsWith("{") && value.asString().endsWith("}") -> value.asString()
//
//            // Número
//            value.asDouble() != 0.0 -> value.asDouble()
//
//            // Valor booleano
//            value.asBoolean() -> value.asBoolean()
//
//            // Cadena de texto
//            value.asString().isNotBlank() -> value.asString()
//
//            else -> {
//                Log.w(TAG, "Remote Config: Clave no encontrada o tipo no compatible")
//                null
//            }
//        }

    }
}