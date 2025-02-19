#include "GodotFirebaseAuth.h"


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

// Extraer lógica para obtener el RootViewController
UIViewController* GodotFirebaseAuth::get_root_view_controller() const {
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            return scene.keyWindow.rootViewController;
        }
    }
    NSLog(@"[GodotFirebaseAuth]: Error - No se pudo obtener el RootViewController");
    return NULL;
}

// Extraer lógica para crear un diccionario con detalles del usuario
Dictionary GodotFirebaseAuth::create_user_data(FIRUser *user) const {
    Dictionary user_data;
    user_data["uid"] = String(user.uid.UTF8String);
    user_data["email"] = user.email != NULL ? String(user.email.UTF8String) : "";
    user_data["display_name"] = user.displayName != NULL ? String(user.displayName.UTF8String) : "";
    user_data["photo_url"] = user.photoURL != NULL ? String([[user.photoURL absoluteString] UTF8String]) : "";
    user_data["is_anonymous"] = user.isAnonymous;
    return user_data;
}

// Método para iniciar sesión con Google
void GodotFirebaseAuth::sign_in_with_google() {
    NSLog(@"[GodotFirebaseAuth]: Attempt signin with Google");

    UIViewController *root_view_controller = get_root_view_controller();
    if (!root_view_controller) return;

    NSString *client_id = [FIRApp defaultApp].options.clientID;
    if (!client_id) {
        NSLog(@"[GodotFirebaseAuth]: Error - No se pudo obtener el clientID");
        return;
    }

    GIDConfiguration *config = [[GIDConfiguration alloc] initWithClientID:client_id];
    [GIDSignIn sharedInstance].configuration = config;
    NSLog(@"[GodotFirebaseAuth]: Google Sign-In configurado correctamente con Client ID");

    [[GIDSignIn sharedInstance] signInWithPresentingViewController:root_view_controller
        completion:^(GIDSignInResult * _Nullable result, NSError * _Nullable error) {
            if (error || !result) {
                NSLog(@"[GodotFirebaseAuth]: Error al iniciar sesión con Google: %@", error.localizedDescription);
                emit_signal("google_login_failed", String(error.localizedDescription.UTF8String));
                return;
            }

            FIRAuthCredential *credential = [FIRGoogleAuthProvider
                credentialWithIDToken:result.user.idToken.tokenString
                           accessToken:result.user.accessToken.tokenString];

            FIRUser *current_user = [FIRAuth auth].currentUser;

            // Verifica si el usuario actual es anónimo
            if (current_user.isAnonymous) {
                // Intenta vincular la cuenta anónima con las credenciales de Google
                [current_user linkWithCredential:credential
                                      completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                    if (error) {
                        // Manejar error de credencial ya asociada a otra cuenta
                        if (error.code == FIRAuthErrorCodeCredentialAlreadyInUse) {
                            NSLog(@"[GodotFirebaseAuth]: Esta credencial ya está asociada con otra cuenta.");

                            // Obtener el usuario existente que tiene la credencial
                            FIRAuthCredential *existingCredential = error.userInfo[@"FIRAuthErrorUserInfoUpdatedCredentialKey"];
//                            FIRAuthCredential *existingCredential = error.userInfo[FIRAuthUpdatedCredentialKey];
                            NSLog(@"[GodotFirebaseAuth]: existingCredential: %@", existingCredential);

                            // Cerrar la cuenta anónima actual antes de iniciar sesión
                            [current_user deleteWithCompletion:^(NSError * _Nullable deleteError) {
                                if (deleteError) {
                                    NSLog(@"[GodotFirebaseAuth]: No se pudo eliminar la cuenta anónima: %@", deleteError.localizedDescription);
                                    emit_signal("google_login_failed",
                                        "Failed to delete anonymous account: " + String(deleteError.localizedDescription.UTF8String));
                                    return;
                                }

                                // Iniciar sesión con la credencial existente (Google)
                                [[FIRAuth auth] signInWithCredential:existingCredential
                                                           completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable signInError) {
                                    if (signInError) {
                                        NSLog(@"[GodotFirebaseAuth]: Error al iniciar sesión con las credenciales existentes: %@", signInError.localizedDescription);
                                        emit_signal("google_login_failed", String(signInError.localizedDescription.UTF8String));
                                    } else {
                                        emit_signal("google_login_success", create_user_data(authResult.user));
                                        NSLog(@"[GodotFirebaseAuth]: Inicio de sesión exitoso. UID: %@", authResult.user.uid);
                                    }
                                }];
                            }];
                        } else {
                            // Otros errores de vinculación
                            NSLog(@"[GodotFirebaseAuth]: Error al vincular cuenta anónima con Google: %@", error.localizedDescription);
                            emit_signal("google_login_failed", String(error.localizedDescription.UTF8String));
                        }
                    } else {
                        // Vinculación exitosa
                        emit_signal("google_login_success", create_user_data(authResult.user));
                        NSLog(@"[GodotFirebaseAuth]: Cuenta anónima vinculada con éxito. UID: %@", authResult.user.uid);
                    }
                }];
            } else {
                // Si el usuario no es anónimo, intenta iniciar sesión directamente con las credenciales de Google
                [[FIRAuth auth] signInWithCredential:credential
                                           completion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
                    if (error) {
                        NSLog(@"[GodotFirebaseAuth]: Error al autenticar con Firebase usando Google: %@", error.localizedDescription);
                        emit_signal("google_login_failed", String(error.localizedDescription.UTF8String));
                    } else {
                        emit_signal("google_login_success", create_user_data(authResult.user));
                        NSLog(@"[GodotFirebaseAuth]: Inicio de sesión con éxito. UID: %@", authResult.user.uid);
                    }
                }];
            }
        }
    ];
}


// Método para iniciar sesión anónima
void GodotFirebaseAuth::sign_in_anonymously() {
    NSLog(@"[GodotFirebaseAuth]: sign_in_anonymously");
    FIRAuth *auth = [FIRAuth auth];
    [auth signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult, NSError * _Nullable error) {
        if (error) {
            // Emitir señal de error con el mensaje
            emit_signal("anonymous_login_failed", String(error.localizedDescription.UTF8String));
            NSLog(@"Error al autenticarse: %@", error.localizedDescription);
        } else if (authResult != NULL && authResult.user != NULL) {
            // Construir un diccionario con la información del usuario
            Dictionary user_data = create_user_data(authResult.user);

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
                        Dictionary user_data = create_user_data(newAuthResult.user);

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
            Dictionary user_data = create_user_data(authResult.user);

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

        return create_user_data(current_user); // Devolver la información como un Dictionary
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
