//
//  in_app_store_module.cpp
//  in_app_store
//
//  Created by Daniel Roke on 24.11.24.
//


#include "core/config/engine.h"


#include "in_app_store_module.h"

InAppStore *store_kit;

void register_inappstore_types() {
    store_kit = memnew(InAppStore);
    Engine::get_singleton()->add_singleton(Engine::Singleton("InAppStore", store_kit));
}

void unregister_inappstore_types() {
    if (store_kit) {
        memdelete(store_kit);
    }
}
