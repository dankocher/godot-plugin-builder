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

// Método para iniciar sesión anónima
//void GodotFirebaseAuth::sign_in_with_google() {
//    
//}

// Método para iniciar sesión anónima
void GodotFirebaseAuth::sign_in_anonymously() {
//    [SwiftAuthManager.shared signInAnonymously]; // Llama al método Swift
//    FUIAuth *authUi = [FUIAuth defaultAuthUI];
//    FIRAuth *auth = [authUi auth];
//    NSLog(@"Unsupported Firebase parameter type: %@", [auth]);
    
//    [auth signInAnonymouslyWithCompletion:^(FIRAuthDataResult * _Nullable authResult,
//                                                      NSError * _Nullable error) {
//       // ...
//     }];
}

// Método para cerrar sesión
void GodotFirebaseAuth::sign_out() {
//    [SwiftAuthManager.shared signOut]; // Llama al método Swift
}

// Método para obtener información del usuario actual
Variant GodotFirebaseAuth::get_current_user() {
    // Llama al método Swift para obtener información del usuario y convertir su respuesta
//    NSDictionary *userInfo = [SwiftAuthManager.shared getCurrentUser];
//    if (userInfo) {
//        Dictionary user_info;
//        user_info["uid"] = String([[userInfo objectForKey:@"uid"] UTF8String]);
//        user_info["email"] = String([[userInfo objectForKey:@"email"] UTF8String]);
//        user_info["display_name"] = String([[userInfo objectForKey:@"displayName"] UTF8String]);
//        return user_info;
//    }
    return Variant(); // Retorna nulo si no hay un usuario conectado
}

// Vincular métodos y señales con la API de Godot
void GodotFirebaseAuth::_bind_methods() {
    ADD_SIGNAL(MethodInfo("login_success", PropertyInfo(Variant::STRING, "user_id")));
    ADD_SIGNAL(MethodInfo("login_failed", PropertyInfo(Variant::STRING, "error_message")));

    ADD_SIGNAL(MethodInfo("signup_success", PropertyInfo(Variant::STRING, "user_id")));
    ADD_SIGNAL(MethodInfo("signup_failed", PropertyInfo(Variant::STRING, "error_message")));

    ADD_SIGNAL(MethodInfo("google_login_success", PropertyInfo(Variant::STRING, "user_id")));
    ADD_SIGNAL(MethodInfo("google_login_failed", PropertyInfo(Variant::STRING, "error_message")));

    ADD_SIGNAL(MethodInfo("signout_success"));
    ADD_SIGNAL(MethodInfo("signout_failed", PropertyInfo(Variant::STRING, "error_message")));

    ADD_SIGNAL(MethodInfo("anonymous_login_success", PropertyInfo(Variant::STRING, "user_id")));
    ADD_SIGNAL(MethodInfo("anonymous_login_failed", PropertyInfo(Variant::STRING, "error_message")));

//    ClassDB::bind_method(D_METHOD("sign_in_with_google"), &GodotFirebaseAuth::sign_in_with_google);
    ClassDB::bind_method(D_METHOD("sign_out"), &GodotFirebaseAuth::sign_out);
    ClassDB::bind_method(D_METHOD("get_current_user"), &GodotFirebaseAuth::get_current_user);
    ClassDB::bind_method(D_METHOD("sign_in_anonymously"), &GodotFirebaseAuth::sign_in_anonymously);
}
