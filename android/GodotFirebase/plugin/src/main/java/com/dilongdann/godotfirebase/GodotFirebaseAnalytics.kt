package com.dilongdann.godotfirebase

import android.app.Activity
import android.os.Bundle
import android.util.Log
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot
import com.google.firebase.analytics.FirebaseAnalytics
import org.godotengine.godot.Dictionary

class GodotFirebaseAnalytics(godot: Godot) : GodotPlugin(godot) {

    // Instancia de Firebase Analytics
    private lateinit var firebaseAnalytics: FirebaseAnalytics
    private val activity: Activity = godot.getActivity() as Activity

    override fun getPluginName(): String {
        return "GodotFirebaseAnalytics"
    }

    /**
     * Inicializa Firebase Analytics.
     */
    @UsedByGodot
    fun initialize() {
        runOnUiThread {
            firebaseAnalytics = FirebaseAnalytics.getInstance(activity)
            Log.v(pluginName, "Firebase Analytics initialized successfully!")
        }
    }

    /**
     * Registra un evento personalizado en Firebase Analytics.
     *
     * @param eventName Nombre del evento (por ejemplo, "purchase")
     * @param params Mapa que contiene los parámetros asociados con el evento
     */
    @UsedByGodot
    fun log_event(eventName: String, params: Dictionary) {
        if (!::firebaseAnalytics.isInitialized) {
            Log.e(pluginName, "Firebase Analytics is not initialized! Call initializeAnalytics() first.")
            return
        }

        val bundle = Bundle()
        for (i in params){
            when (val value: Any = i.value as Any) {
                is Long -> {
                    bundle.putLong(i.key, value.toLong())
                }

                is Int -> {
                    bundle.putInt(i.key, value.toInt())
                }

                is String -> {
                    bundle.putString(i.key, value.toString())
                }

                is Double -> {
                    bundle.putDouble(i.key, value.toDouble())
                }
            }
        }

        firebaseAnalytics.logEvent(eventName, bundle)
        Log.v(pluginName, "Event logged: $eventName with params: $params")
    }

    /**
     * Configura una propiedad del usuario en Firebase Analytics.
     *
     * @param propertyName Nombre de la propiedad (por ejemplo, "favorito_color")
     * @param propertyValue Valor de la propiedad (por ejemplo, "Azul")
     */
    @UsedByGodot
    fun set_user_property(propertyName: String, propertyValue: String) {
        if (!::firebaseAnalytics.isInitialized) {
            Log.e(pluginName, "Firebase Analytics is not initialized! Call initializeAnalytics() first.")
            return
        }

        firebaseAnalytics.setUserProperty(propertyName, propertyValue)
        Log.v(pluginName, "User property set: $propertyName = $propertyValue")
    }

    /**
     * Establece un ID único para identificar al usuario.
     *
     * @param userId Identificador del usuario
     */
    @UsedByGodot
    fun set_user_id(userId: String) {
        if (!::firebaseAnalytics.isInitialized) {
            Log.e(pluginName, "Firebase Analytics is not initialized! Call initializeAnalytics() first.")
            return
        }

        firebaseAnalytics.setUserId(userId)
        Log.v(pluginName, "User ID set: $userId")
    }
}