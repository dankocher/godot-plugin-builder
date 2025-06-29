package com.dilongdann.godotfirebase

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log
import androidx.appcompat.app.AppCompatActivity
import androidx.credentials.Credential
import androidx.credentials.CredentialManager
import androidx.credentials.GetCredentialRequest
import androidx.credentials.exceptions.GetCredentialException
import androidx.lifecycle.lifecycleScope
import com.google.android.libraries.identity.googleid.GetGoogleIdOption
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential
import com.google.android.libraries.identity.googleid.GoogleIdTokenCredential.Companion.TYPE_GOOGLE_ID_TOKEN_CREDENTIAL
import com.google.firebase.auth.FirebaseAuth
import com.google.firebase.auth.FirebaseUser
import com.google.firebase.auth.GoogleAuthProvider
import kotlinx.coroutines.launch
import org.godotengine.godot.Dictionary

class GoogleSignInActivity() : AppCompatActivity() {

    private lateinit var credentialManager: CredentialManager
    private lateinit var auth: FirebaseAuth

    companion object {
//        lateinit var godotActivity: Activity

        private const val TAG = "GoogleSignInActivity"
        const val SIGN_IN_SUCCESS = "SIGN_IN_SUCCESS"
        const val SIGN_IN_FAILURE = "SIGN_IN_FAILURE"
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        credentialManager = CredentialManager.create(baseContext)
        auth = FirebaseAuth.getInstance()
        launchCredentialManager()
    }

    private fun launchCredentialManager() {
        // [START create_credential_manager_request]
        // Instantiate a Google sign-in request
        val googleIdOption = GetGoogleIdOption.Builder()
            // Your server's client ID, not your Android client ID.
            .setServerClientId(getString(R.string.default_web_client_id))
            // Only show accounts previously used to sign in.
            .setFilterByAuthorizedAccounts(true)
            .build()

        // Create the Credential Manager request
        val request = GetCredentialRequest.Builder()
            .addCredentialOption(googleIdOption)
            .build()
        // [END create_credential_manager_request]

        Log.d(TAG, getString(R.string.default_web_client_id))

        lifecycleScope.launch {
            try {
                // Launch Credential Manager UI
                val result = credentialManager.getCredential(
                    context = this@GoogleSignInActivity,
                    request = request
                )

                // Extract credential from the result returned by Credential Manager
                handleSignIn(result.credential)
            } catch (e: GetCredentialException) {
                Log.e(TAG, "Couldn't retrieve user's credentials: ${e.localizedMessage}")
            }
        }
    }

    private fun handleSignIn(credential: Credential) {
        if (credential is GoogleIdTokenCredential && credential.type == TYPE_GOOGLE_ID_TOKEN_CREDENTIAL) {
            val idToken = credential.idToken
            firebaseAuthWithGoogle(idToken)
        } else {
            returnFailure("Credenciales no válidas.")
        }
    }

    private fun firebaseAuthWithGoogle(idToken: String) {
        val credential = GoogleAuthProvider.getCredential(idToken, null)
        auth.signInWithCredential(credential)
            .addOnCompleteListener(this) { task ->
                if (task.isSuccessful) {
                    Log.d(TAG, "Autenticación exitosa.")
                    val user = auth.currentUser
                    returnSuccess(user)
                } else {
                    Log.e(TAG, "Error al autenticar con Firebase.", task.exception)
                    returnFailure(task.exception?.localizedMessage ?: "Error desconocido")
                }
            }
    }

    // Success result
    private fun returnSuccess(user: FirebaseUser?) {
        val resultIntent = Intent().apply {
            putExtra("success", true)
//            putExtra("user", user?.toDictionary()) // Usando tu método userToDictionary
        }
        setResult(Activity.RESULT_OK, resultIntent)
        finish()

    }

    // Failure result
    private fun returnFailure(error: String) {
        val resultIntent = Intent().apply {
            putExtra("success", false)
            putExtra("error", error)
        }
        setResult(Activity.RESULT_CANCELED, resultIntent)
        finish()
    }

    private fun userToDictionary(user: FirebaseUser?): Dictionary {
        val userData = Dictionary()
        if (user != null) {
            userData["uid"] = user.uid
            userData["email"] = user.email
            userData["displayName"] = user.displayName
            userData["photoUrl"] = user.photoUrl?.toString()
            userData["phoneNumber"] = user.phoneNumber
            userData["isAnonymous"] = user.isAnonymous
        }
        return userData
    }

    override fun onDestroy() {
        super.onDestroy()
    }

}