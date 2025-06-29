#import "GodotFirebaseFunctions.h"

GodotFirebaseFunctions *GodotFirebaseFunctions::instance = nullptr;

GodotFirebaseFunctions::GodotFirebaseFunctions() {
    ERR_FAIL_COND(instance != nullptr);
    instance = this;

    // Inicializa la instancia de FirebaseFunctions
    functions_instance = [FIRFunctions functions];
    NSLog(@"[GodotFirebaseFunctions] Plugin initialized.");
}

GodotFirebaseFunctions::~GodotFirebaseFunctions() {
    if (instance == this) {
        instance = nullptr;
    }
}

GodotFirebaseFunctions *GodotFirebaseFunctions::get_singleton() {
    return instance;
}

void GodotFirebaseFunctions::_bind_methods() {
    ADD_SIGNAL(MethodInfo("function_success", PropertyInfo(Variant::DICTIONARY, "data")));
    ADD_SIGNAL(MethodInfo("function_failure", PropertyInfo(Variant::DICTIONARY, "error")));

    ClassDB::bind_method(D_METHOD("call_function", "name", "data", "callback"), &GodotFirebaseFunctions::call_function);
    ClassDB::bind_method(D_METHOD("use_emulator", "host", "port"), &GodotFirebaseFunctions::use_emulator);
}

/**
 * Configura un emulador de Firebase Functions.
 */
void GodotFirebaseFunctions::use_emulator(String host, int port) {
    NSString *nsHost = [NSString stringWithUTF8String:host.utf8().get_data()];
    [functions_instance useEmulatorWithHost:nsHost port:port];
    NSLog(@"[GodotFirebaseFunctions] Emulator set to %@:%d.", nsHost, port);
}

/**
 * Llama a una función en Firebase Functions.
 */
void GodotFirebaseFunctions::call_function(String name, Dictionary data, String callback) {
    NSString *functionName = [NSString stringWithUTF8String:name.utf8().get_data()];
    NSMutableDictionary *firebaseData = [NSMutableDictionary dictionary];
    Array keys = data.keys();

    // Convierte el Dictionary de Godot a un NSDictionary
    for (int i = 0; i < keys.size(); i++) {
        String key = keys[i];
        Variant value = data[key];
        NSString *objcKey = [NSString stringWithUTF8String:key.utf8().get_data()];

        firebaseData[objcKey] = convert_variant_to_nsobject(value);
    }

    // Llama a la función de Firebase
    [[functions_instance HTTPSCallableWithName:functionName]
        callWithObject:firebaseData
        completion:^(FIRHTTPSCallableResult *result, NSError *error) {
            // Maneja errores
            if (error != nil) {
                Dictionary errorData;
                errorData["code"] = static_cast<int64_t>(error.code);
                errorData["message"] = String(error.localizedDescription.UTF8String);
                emit_signal("function_failure", errorData);
                return;
            }

            // Maneja el resultado exitoso
            if ([result.data isKindOfClass:[NSDictionary class]]) {
                NSDictionary *resultDict = result.data;
                Dictionary data;

                for (NSString *key in resultDict.allKeys) {
                    data[String(key.UTF8String)] = nsobject_to_variant(resultDict[key]);
                }

                Dictionary godotResult;

                godotResult["success"] = true;
                godotResult["data"] = data;
                godotResult["callback"] = callback;

                emit_signal("function_success", godotResult);
            } else {
                Dictionary unexpectedResult;
                unexpectedResult["success"] = false;
                unexpectedResult["error"] = "Unexpected result format";
                unexpectedResult["callback"] = callback;
                emit_signal("function_failure", unexpectedResult);
            }
        }];
}

/**
 * Convierte un Variant de Godot a un NSObject de Objective-C.
 */
NSObject *GodotFirebaseFunctions::convert_variant_to_nsobject(Variant value) {
    switch (value.get_type()) {
        case Variant::Type::BOOL:
            return [NSNumber numberWithBool:(bool)value];
        case Variant::Type::INT:
            return [NSNumber numberWithLongLong:(int64_t)value];
        case Variant::Type::FLOAT:
            return [NSNumber numberWithDouble:(double)value];
        case Variant::Type::STRING: {
            String str = value;
            return [NSString stringWithUTF8String:str.utf8().get_data()];
        }
        case Variant::Type::DICTIONARY: {
            Dictionary godotDict = value;
            NSMutableDictionary *mutableDict = [NSMutableDictionary dictionary];
            Array keys = godotDict.keys();
            for (int i = 0; i < keys.size(); i++) {
                String key = keys[i];
                NSString *nsKey = [NSString stringWithUTF8String:key.utf8().get_data()];
                mutableDict[nsKey] = convert_variant_to_nsobject(godotDict[key]);
            }
            return mutableDict;
        }
        case Variant::Type::ARRAY: {
            Array godotArray = value;
            NSMutableArray *mutableArray = [NSMutableArray array];
            for (int i = 0; i < godotArray.size(); i++) {
                [mutableArray addObject:convert_variant_to_nsobject(godotArray[i])];
            }
            return mutableArray;
        }
        default:
            return [NSNull null];
    }
}


/**
 * Convierte un NSObject de Objective-C a un Variant de Godot.
 */
Variant GodotFirebaseFunctions::nsobject_to_variant(NSObject *object) {
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)object;
        return number.intValue;
    } else if ([object isKindOfClass:[NSString class]]) {
        return Variant(String(((NSString *)object).UTF8String));
    } else if ([object isKindOfClass:[NSDictionary class]]) {
        Dictionary result;
        NSDictionary *dict = (NSDictionary *)object;

        for (NSString *key in dict.allKeys) {
            result[String(key.UTF8String)] = nsobject_to_variant(dict[key]);
        }
        return result;
    } else if ([object isKindOfClass:[NSArray class]]) {
        Array result;
        NSArray *array = (NSArray *)object;

        for (NSObject *item in array) {
            result.append(nsobject_to_variant(item));
        }
        return result;
    }
    return Variant();
}
