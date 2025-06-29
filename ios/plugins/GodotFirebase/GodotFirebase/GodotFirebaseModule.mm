#import "GodotFirebaseModule.h"


GodotFirebase *godot_firebase;
GodotFirebaseAnalytics *godot_firebase_analytics;
GodotFirebaseRemoteConfig *godot_firebase_remote_config;
GodotFirebaseAuth *godot_firebase_auth;
GodotFirebaseFirestore *godot_firebase_firestore;
GodotFirebaseFunctions *godot_firebase_functions;


void register_godot_firebase() {
    godot_firebase = memnew(GodotFirebase);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotFirebase", godot_firebase));

    godot_firebase_analytics = memnew(GodotFirebaseAnalytics);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotFirebaseAnalytics", godot_firebase_analytics));

    godot_firebase_remote_config = memnew(GodotFirebaseRemoteConfig);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotFirebaseRemoteConfig", godot_firebase_remote_config));

    godot_firebase_auth = memnew(GodotFirebaseAuth);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotFirebaseAuth", godot_firebase_auth));

    godot_firebase_firestore = memnew(GodotFirebaseFirestore);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotFirebaseFirestore", godot_firebase_firestore));

    godot_firebase_functions = memnew(GodotFirebaseFunctions);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotFirebaseFunctions", godot_firebase_functions));

}

void unregister_godot_firebase() {
    if (godot_firebase) {
        memdelete(godot_firebase);
    }
    if (godot_firebase_analytics) {
        memdelete(godot_firebase_analytics);
    }
    if (godot_firebase_remote_config) {
        memdelete(godot_firebase_remote_config);
    }
    if (godot_firebase_auth) {
        memdelete(godot_firebase_auth);
    }
    if (godot_firebase_firestore) {
        memdelete(godot_firebase_firestore);
    }
    if (godot_firebase_functions) {
        memdelete(godot_firebase_functions);
    }

}
