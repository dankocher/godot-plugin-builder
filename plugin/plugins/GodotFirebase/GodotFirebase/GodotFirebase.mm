#import "GodotFirebase.h"

GodotFirebase *GodotFirebase::instance = NULL;

GodotFirebase::GodotFirebase() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
}

GodotFirebase::~GodotFirebase() {
    if (instance == this) {
        instance = NULL;
    }
}

GodotFirebase *GodotFirebase::get_singleton() {
    return instance;
}

bool GodotFirebase::initialize() {
    NSLog(@"Firebase Initialize");
//    if ([FIRApp defaultApp] == nil) {
//        [FIRApp configure]; // Configura Firebase
//        emit_signal("firebase_initialized");
//    }
    
    [FIRApp configure]; // Configura Firebase
    emit_signal("firebase_initialized");
    return true;
}

void GodotFirebase::_bind_methods() {
    ADD_SIGNAL(MethodInfo("firebase_initialized"));
    ClassDB::bind_method(D_METHOD("initialize"), &GodotFirebase::initialize);
}
