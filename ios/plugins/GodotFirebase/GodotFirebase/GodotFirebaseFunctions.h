#ifndef GODOT_FIREBASE_FUNCTIONS_H
#define GODOT_FIREBASE_FUNCTIONS_H

#import <Foundation/Foundation.h>
#import <FirebaseFunctions/FirebaseFunctions-umbrella.h>
#include "core/object/class_db.h"

class GodotFirebaseFunctions : public Object {
    GDCLASS(GodotFirebaseFunctions, Object);

private:
    static GodotFirebaseFunctions *instance;
    FIRFunctions *functions_instance;

protected:
    static void _bind_methods();

    NSObject *convert_variant_to_nsobject(Variant value);
    Variant nsobject_to_variant(NSObject *object);

public:
    static GodotFirebaseFunctions *get_singleton();

    // Métodos del plugin
    void call_function(String name, Dictionary data, String callback);
    void use_emulator(String host, int port);

    GodotFirebaseFunctions();
    ~GodotFirebaseFunctions();
};

#endif
