#ifndef GODOT_FIREBASE_ANALYTICS_H
#define GODOT_FIREBASE_ANALYTICS_H

#import <Foundation/Foundation.h>
#import <FirebaseAnalytics/FIRAnalytics.h>
#include "core/object/class_db.h"

class GodotFirebaseAnalytics : public Object {
    GDCLASS(GodotFirebaseAnalytics, Object);

private:
    static GodotFirebaseAnalytics *instance;

protected:
    static void _bind_methods();

public:
    static GodotFirebaseAnalytics *get_singleton();

    void log_event(String event_name, Dictionary parameters);
    void set_user_property(String name, String value);

    GodotFirebaseAnalytics();
    ~GodotFirebaseAnalytics();
};

#endif
