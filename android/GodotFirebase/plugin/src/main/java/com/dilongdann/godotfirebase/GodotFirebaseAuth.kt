package com.dilongdann.godotfirebase

import android.app.Activity
import android.content.Intent
import android.util.Log
import androidx.credentials.GetCredentialRequest
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.GoogleAuthProvider
import com.google.android.gms.common.api.ApiException
import org.godotengine.godot.Dictionary
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class GodotFirebaseAuth(godot: Godot) : GodotPlugin(godot) {

    private val activity: Activity = godot.getActivity() as Activity
    private lateinit var auth: FirebaseAuth
    private lateinit var googleSignIn: GoogleSignInActivity

    companion object {
        private const val RC_SIGN_IN = 9001 // Request code para Google Sign-In
        private const val TAG = "GodotFirebaseAuth"
    }

    init {
        auth = FirebaseAuth.getInstance()
    }

    override fun getPluginName(): String {
        return "GodotFirebaseAuth"
    }

    override fun getPluginSignals(): MutableSet<SignalInfo> {
        return mutableSetOf(
            SignalInfo("sign_in_success", Dictionary::class.java),
            SignalInfo("sign_in_failure", String::class.java)
        )
    }

    /**
     * Iniciar sesión de forma anónima.
     */
    @UsedByGodot
    fun sign_in_anonymously() {
        auth.signInAnonymously()
            .addOnCompleteListener(activity) { task ->
                if (task.isSuccessful) {
                    emitSignal("sign_in_success", get_current_user())
                    Log.v(TAG, "Anonymous sign-in successful.")
                } else {
                    emitSignal("sign_in_failure", task.exception?.localizedMessage ?: "Unknown error")
                    Log.e(TAG, "Anonymous sign-in failed.", task.exception)
                }
            }
    }

    /**
     * Iniciar sesión con Google.
     */
    @UsedByGodot
    fun sign_in_with_google() {
//        GoogleSignInActivity.godotActivity = activity
        val signInIntent = Intent(activity, GoogleSignInActivity::class.java)
        activity.startActivityForResult(signInIntent, RC_SIGN_IN)
    }
    // Manejar el resultado
    override fun onMainActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == RC_SIGN_IN) {
            if (resultCode == Activity.RESULT_OK) {
                val success = data?.getBooleanExtra("success", false) ?: false
                if (success) {
//                    val userDict = data?.getSerializableExtra("user") as Dictionary
                    emitSignal("sign_in_success", get_current_user())
                } else {
                    val error = data?.getStringExtra("error") ?: "Unknown error"
                    emitSignal("sign_in_failure", error)
                }
            } else {
                emitSignal("sign_in_failure", "Result canceled or failed")
            }
        }
    }


    /**
     * Obtener al usuario autenticado.
     */
    @UsedByGodot
    fun get_current_user(): Dictionary? {
        val user = auth.currentUser
        if (user != null) {
            // Devuelve un Dictionary con los datos del usuario
            val userData = Dictionary()
            userData["uid"] = user.uid // Identificador único del usuario
            userData["email"] = user.email // Correo electrónico del usuario (si está disponible)
            userData["displayName"] = user.displayName // Nombre visible del usuario (si está disponible)
            userData["photoUrl"] = user.photoUrl?.toString() // URL de la foto del usuario (si está disponible)
            userData["phoneNumber"] = user.phoneNumber // Número de teléfono del usuario (si está disponible)
            userData["isAnonymous"] = user.isAnonymous // Si el usuario es anónimo o no
            return userData

        } else {
            // Si no hay usuario autenticado
            return null
        }


    }
}