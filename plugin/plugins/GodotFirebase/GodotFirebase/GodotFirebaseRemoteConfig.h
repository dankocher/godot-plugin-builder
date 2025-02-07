#ifndef GODOT_FIREBASE_REMOTE_CONFIG_H
#define GODOT_FIREBASE_REMOTE_CONFIG_H

#import <Foundation/Foundation.h>
#import <FirebaseRemoteConfig/FIRRemoteConfig.h>
#include "core/object/class_db.h"

class GodotFirebaseRemoteConfig : public Object {
    GDCLASS(GodotFirebaseRemoteConfig, Object);

private:
    static GodotFirebaseRemoteConfig *instance;

protected:
    static void _bind_methods();

public:
    static GodotFirebaseRemoteConfig *get_singleton();

    void fetch_remote_config();
    Variant get_remote_config_value(String key);

    GodotFirebaseRemoteConfig();
    ~GodotFirebaseRemoteConfig();
};

#endif
