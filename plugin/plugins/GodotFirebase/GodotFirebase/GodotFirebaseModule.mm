#import "GodotFirebaseModule.h"


GodotFirebase *godot_firebase;
GodotFirebaseAnalytics *godot_firebase_analytics;
GodotFirebaseRemoteConfig *godot_firebase_remote_config;

void register_godot_firebase() {
    godot_firebase = memnew(GodotFirebase);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotFirebase", godot_firebase));

    godot_firebase_analytics = memnew(GodotFirebaseAnalytics);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotFirebaseAnalytics", godot_firebase_analytics));

    godot_firebase_remote_config = memnew(GodotFirebaseRemoteConfig);
    Engine::get_singleton()->add_singleton(Engine::Singleton("GodotFirebaseRemoteConfig", godot_firebase_remote_config));
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
}
