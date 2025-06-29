package com.dilongdann.godotfirebase

import android.app.Activity
import android.util.Log
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.UsedByGodot

import com.google.firebase.FirebaseApp

class GodotFirebase(godot: Godot) : GodotPlugin(godot) {

    private val activity: Activity = godot.getActivity() as Activity

    override fun getPluginName(): String {
        return "GodotFirebase"
    }

    @UsedByGodot
    fun initialize() {
        runOnUiThread {
            FirebaseApp.initializeApp(activity)
            Log.v(pluginName, "Firebase initialized successfully!")
        }
    }
}