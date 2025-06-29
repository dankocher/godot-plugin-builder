#ifndef GODOT_FIREBASE_MODULE_H
#define GODOT_FIREBASE_MODULE_H

#include "core/config/engine.h"

#include "GodotFirebase.h"
#include "GodotFirebaseAnalytics.h"
#include "GodotFirebaseRemoteConfig.h"
#include "GodotFirebaseAuth.h"
#include "GodotFirebaseFirestore.h"
#include "GodotFirebaseFunctions.h"


void register_godot_firebase();
void unregister_godot_firebase();

#endif
