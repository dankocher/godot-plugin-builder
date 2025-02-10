#ifndef GODOT_FIREBASE_H
#define GODOT_FIREBASE_H

#import <Foundation/Foundation.h>
#import <FirebaseCore/FirebaseCore.h>

#include "core/object/class_db.h"


class GodotFirebase : public Object {
    GDCLASS(GodotFirebase, Object);
    
private:
    static GodotFirebase *instance;

protected:
    static void _bind_methods();

public:

    bool initialize();
    
    static GodotFirebase *get_singleton();

    GodotFirebase();
    ~GodotFirebase();
};

#endif
