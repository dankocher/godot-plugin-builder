#import "GodotFirebase.h"

GodotFirebase *GodotFirebase::instance = nullptr;

GodotFirebase::GodotFirebase() {
    ERR_FAIL_COND(instance != nullptr);
    instance = this;

    // Configurar Firebase
    if (![FIRApp defaultApp]) {
        [FIRApp configure];
        NSLog(@"[GodotFirebase] Firebase configured successfully");
    }
}

GodotFirebase::~GodotFirebase() {
    if (instance == this) {
        instance = nullptr;
    }
}

GodotFirebase *GodotFirebase::get_singleton() {
    return instance;
}

void GodotFirebase::_bind_methods() {
    ClassDB::bind_method(D_METHOD("initialize"), &GodotFirebase::initialize);
}

void GodotFirebase::initialize() {
    // Método adicional por si necesitas inicialización extra
    NSLog(@"[GodotFirebase] Additional initialization if needed");
}
