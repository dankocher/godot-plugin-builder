#include "GodotFirebaseAuth.h"

#import <FirebaseCore/FirebaseCore.h>

#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleSignIn/GIDSignIn.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseAuth/FirebaseAuth-Swift.h>



//#import "GodotFirebaseAuthBridge.h" // Importa la clase puente

GodotFirebaseAuth *GodotFirebaseAuth::instance = NULL;

// Constructor
GodotFirebaseAuth::GodotFirebaseAuth() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;

//    // Crea una instancia del puente
//    @autoreleasepool {
//        [[GodotFirebaseAuthBridge alloc] initWithCPPInstance:this];
//    }
}

// Destructor
GodotFirebaseAuth::~GodotFirebaseAuth() {
    if (instance == this) {
        instance = NULL;
    }
}

// Método para obtener el singleton
GodotFirebaseAuth *GodotFirebaseAuth::get_singleton() {
    return instance;
}

// Método para iniciar sesión con Google

void GodotFirebaseAuth::sign_in_with_google() {
    // Obtener el ViewController principal necesario para el flujo de autenticación
    UIViewController *rootViewController;

    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                rootViewController = scene.keyWindow.rootViewController;
                break;
            }
        }


    [[GIDSignIn sharedInstance] signInWithPresentingViewController:rootViewController
        completion:^(GIDSignInResult * _Nullable result, NSError * _Nullable error) {
            if (error || !result) {
                NSLog(@"[GodotFirebaseAuth]: Error al iniciar sesión con Google: %@", error.localizedDescription);
                emit_signal("google_login_failed", String(error.localizedDescription.UTF8String));
                return;
            }

            // Obtén los tokens de autenticación de Google
            GIDGoogleUser *user = result.user;
            NSString *idToken = user.idToken.tokenString;
            NSString *accessToken = user.accessToken.tokenString;

            // Crea credenciales de Firebase con los tokens proporcionados por Google
            FIRAuthCredential *credential = [FIRGoogleAuthProvider credentialWithIDToken:idToken accessToken:accessToken];

            // Inicia sesión en Firebase con las credenciales
            [[FIRAuth auth] signInWithCredential:credential
                                      completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"[GodotFirebaseAuth]: Error al autenticar con Firebase usando Google: %@", error.localizedDescription);
                    emit_signal("google_login_failed", String(error.localizedDescription.UTF8String));
                } else {
                    Dictionary user_data;
                    user_data["uid"] = String(authResult.user.uid.UTF8String);
                    user_data["email"] = authResult.user.email != NULL ? String(authResult.user.email.UTF8String) : "";
                    user_data["display_name"] = authResult.user.displayName != NULL ? String(authResult.user.displayName.UTF8String) : "";
                    user_data["is_anonymous"] = authResult.user.anonymous;

                    // Emitir señal de éxito con los datos del usuario
                    emit_signal("google_login_success", user_data);
                    NSLog(@"Inicio de sesión con éxito. UID: %@", authResult.user.uid);

                }
            }];
        }];
}


// Método para iniciar sesión anónima
void GodotFirebaseAuth::sign_in_anonymously() {
    FIRAuth *auth = [FIRAuth auth];
    [auth signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if (error) {
            // Emitir señal de error con el mensaje
            emit_signal("anonymous_login_failed", String(error.localizedDescription.UTF8String));
            NSLog(@"Error al autenticarse: %@", error.localizedDescription);
        } else if (authResult != NULL && authResult.user != NULL) {
            // Construir un diccionario con la información del usuario
            Dictionary user_data;
            user_data["uid"] = String(authResult.user.uid.UTF8String);
            user_data["email"] = authResult.user.email != NULL ? String(authResult.user.email.UTF8String) : "";
            user_data["display_name"] = authResult.user.displayName != NULL ? String(authResult.user.displayName.UTF8String) : "";
            user_data["is_anonymous"] = authResult.user.anonymous;

            // Emitir señal de éxito con el diccionario del usuario
            emit_signal("anonymous_login_success", user_data);
            NSLog(@"Autenticado como usuario anónimo con UID: %@", authResult.user.uid);
        } else {
            // Emitir señal genérica de error si no hay detalles de usuario ni error
            emit_signal("anonymous_login_failed", "Authentication failed for an unknown reason.");
            NSLog(@"Error desconocido al autenticar.");
        }
    }];
}

void GodotFirebaseAuth::sign_in_with_email(const String &email, const String &password) {
    FIRAuth *auth = [FIRAuth auth];

    // Convertir los strings de Godot a NSString
    NSString *nsEmail = [NSString stringWithUTF8String:email.utf8().get_data()];
    NSString *nsPassword = [NSString stringWithUTF8String:password.utf8().get_data()];

    // Intentar iniciar sesión con el email y contraseña
    [auth signInWithEmail:nsEmail
                 password:nsPassword
               completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {

        if (error) {
            // Si hay error, verificar si se debe a que el usuario no existe (código 17011)
            if (error.code == FIRAuthErrorCodeUserNotFound) {
                // Intentar crear la cuenta con el email y contraseña
                [auth createUserWithEmail:nsEmail
                                 password:nsPassword
                               completion:^(FIRAuthDataResult * _Nullable newAuthResult, NSError * _Nullable newError) {

                    if (newError) {
                        // Emitir señal de fallo al crear la cuenta
                        emit_signal("email_login_failed", String(newError.localizedDescription.UTF8String));
                        NSLog(@"Error al crear usuario: %@", newError.localizedDescription);
                    } else {
                        Dictionary user_data;
                        user_data["uid"] = String(newAuthResult.user.uid.UTF8String);
                        user_data["email"] = newAuthResult.user.email != NULL ? String(newAuthResult.user.email.UTF8String) : "";
                        user_data["display_name"] = newAuthResult.user.displayName != NULL ? String(newAuthResult.user.displayName.UTF8String) : "";
                        user_data["is_anonymous"] = newAuthResult.user.isAnonymous;

                        // Emitir señal de éxito al crear la cuenta y loguear
                        emit_signal("email_login_success", user_data);
                        NSLog(@"Usuario creado e iniciado sesión. UID: %@", newAuthResult.user.uid);
                    }
                }];
            } else {
                // Emitir señal de error general de inicio de sesión
                emit_signal("email_login_failed", String(error.localizedDescription.UTF8String));
                NSLog(@"Error al iniciar sesión: %@", error.localizedDescription);
            }
        } else {
            // Si el inicio de sesión fue exitoso
            Dictionary user_data;
            user_data["uid"] = String(authResult.user.uid.UTF8String);
            user_data["email"] = authResult.user.email != NULL ? String(authResult.user.email.UTF8String) : "";
            user_data["display_name"] = authResult.user.displayName != NULL ? String(authResult.user.displayName.UTF8String) : "";
            user_data["is_anonymous"] = authResult.user.isAnonymous;

            // Emitir señal de éxito
            emit_signal("email_login_success", user_data);
            NSLog(@"Inicio de sesión exitoso. UID: %@", authResult.user.uid);
        }
    }];
}

// Método para cerrar sesión
void GodotFirebaseAuth::sign_out() {
    FIRAuth *auth = [FIRAuth auth];
    NSError *error = nil;

    // Intentar cerrar sesión
    BOOL success = [auth signOut:&error];
    if (success) {
        // Emitir señal de éxito si se cerró la sesión correctamente
        emit_signal("signout_success");
        NSLog(@"Sesión cerrada correctamente.");
    } else {
        // Emitir señal de fallo si ocurre un error
        emit_signal("signout_failed", String(error.localizedDescription.UTF8String));
        NSLog(@"Error al cerrar la sesión: %@", error.localizedDescription);
    }
}

// Método para obtener información del usuario actual
Variant GodotFirebaseAuth::get_current_user() {
    FIRAuth *auth = [FIRAuth auth];
    FIRUser *current_user = auth.currentUser;

    // Comprobar si hay un usuario autenticado
    if (current_user != NULL) {
        // Crear un diccionario para almacenar la información del usuario
        Dictionary user_info;
        user_info["uid"] = String(current_user.uid.UTF8String);
        user_info["email"] = current_user.email != NULL ? String(current_user.email.UTF8String) : "";
        user_info["display_name"] = current_user.displayName != NULL ? String(current_user.displayName.UTF8String) : "";
        user_info["is_anonymous"] = current_user.anonymous;

        return user_info; // Devolver la información como un Dictionary
    }

    // Si no hay usuario autenticado, devolver un Variant vacío
    return Variant();
}

// Vincular métodos y señales con la API de Godot
void GodotFirebaseAuth::_bind_methods() {
    ADD_SIGNAL(MethodInfo("email_login_success", PropertyInfo(Variant::DICTIONARY, "user")));
    ADD_SIGNAL(MethodInfo("email_login_failed", PropertyInfo(Variant::STRING, "error_message")));

    ADD_SIGNAL(MethodInfo("signup_success", PropertyInfo(Variant::DICTIONARY, "user")));
    ADD_SIGNAL(MethodInfo("signup_failed", PropertyInfo(Variant::STRING, "error_message")));

    ADD_SIGNAL(MethodInfo("google_login_success", PropertyInfo(Variant::DICTIONARY, "user")));
    ADD_SIGNAL(MethodInfo("google_login_failed", PropertyInfo(Variant::STRING, "error_message")));

    ADD_SIGNAL(MethodInfo("signout_success"));
    ADD_SIGNAL(MethodInfo("signout_failed", PropertyInfo(Variant::STRING, "error_message")));

    ADD_SIGNAL(MethodInfo("anonymous_login_success", PropertyInfo(Variant::DICTIONARY, "user")));
    ADD_SIGNAL(MethodInfo("anonymous_login_failed", PropertyInfo(Variant::STRING, "error_message")));

    ClassDB::bind_method(D_METHOD("sign_in_with_google"), &GodotFirebaseAuth::sign_in_with_google);
    ClassDB::bind_method(D_METHOD("sign_out"), &GodotFirebaseAuth::sign_out);
    ClassDB::bind_method(D_METHOD("get_current_user"), &GodotFirebaseAuth::get_current_user);
    ClassDB::bind_method(D_METHOD("sign_in_anonymously"), &GodotFirebaseAuth::sign_in_anonymously);
    ClassDB::bind_method(D_METHOD("sign_in_with_email", "email", "password"), &GodotFirebaseAuth::sign_in_with_email);
}
