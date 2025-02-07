
#import "GodotFirebaseAnalytics.h"


GodotFirebaseAnalytics *GodotFirebaseAnalytics::instance = NULL;

GodotFirebaseAnalytics::GodotFirebaseAnalytics() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
}

GodotFirebaseAnalytics::~GodotFirebaseAnalytics() {
    if (instance == this) {
        instance = NULL;
    }
}

GodotFirebaseAnalytics *GodotFirebaseAnalytics::get_singleton() {
    return instance;
}

void GodotFirebaseAnalytics::log_event(String event_name, Dictionary parameters) {
    NSMutableDictionary *firebaseParams = [NSMutableDictionary dictionary];
    Array keys = parameters.keys();
    
    for (int i = 0; i < keys.size(); i++) {
        String key = keys[i];
        Variant value = parameters[key];

        NSString *objcKey = [NSString stringWithUTF8String:key.utf8().get_data()];

        if (value.get_type() == Variant::Type::STRING) {
            firebaseParams[objcKey] = [NSString stringWithUTF8String:value.operator String().utf8().get_data()];
        } else if (value.get_type() == Variant::Type::INT) {
            firebaseParams[objcKey] = @(int(value));
        } else if (value.get_type() == Variant::Type::FLOAT) {
            firebaseParams[objcKey] = @(real_t(value));
        } else if (value.get_type() == Variant::Type::BOOL) {
            firebaseParams[objcKey] = @(bool(value));
        } else {
            const char *type_name = value.get_type_name(value.get_type()).utf8().get_data();
            NSString *unsupportedType = [NSString stringWithUTF8String:type_name];
            NSLog(@"Unsupported Firebase parameter type: %@", unsupportedType);
        }
    }

    [FIRAnalytics logEventWithName:[NSString stringWithUTF8String:event_name.utf8().get_data()]
                        parameters:firebaseParams];
}

void GodotFirebaseAnalytics::set_user_property(String name, String value) {
    [FIRAnalytics setUserPropertyString:[NSString stringWithUTF8String:value.utf8().get_data()]
                                 forName:[NSString stringWithUTF8String:name.utf8().get_data()]];
}

void GodotFirebaseAnalytics::_bind_methods() {
    ClassDB::bind_method(D_METHOD("log_event", "event_name", "parameters"), &GodotFirebaseAnalytics::log_event);
    ClassDB::bind_method(D_METHOD("set_user_property", "name", "value"), &GodotFirebaseAnalytics::set_user_property);
}
