
#import "GodotFirebaseRemoteConfig.h"


GodotFirebaseRemoteConfig *GodotFirebaseRemoteConfig::instance = NULL;

GodotFirebaseRemoteConfig::GodotFirebaseRemoteConfig() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
}

GodotFirebaseRemoteConfig::~GodotFirebaseRemoteConfig() {
    if (instance == this) {
        instance = NULL;
    }
}

GodotFirebaseRemoteConfig *GodotFirebaseRemoteConfig::get_singleton() {
    return instance;
}

void GodotFirebaseRemoteConfig::fetch_remote_config() {
    FIRRemoteConfig *remoteConfig = [FIRRemoteConfig remoteConfig];
    // Ajustar settings (opcional)
    FIRRemoteConfigSettings *settings = [[FIRRemoteConfigSettings alloc] init];
    settings.minimumFetchInterval = 3600; // Actualiza máximo cada hora
    remoteConfig.configSettings = settings;

    // Realizar fetch y activar los valores
    [remoteConfig fetchAndActivateWithCompletionHandler:^(FIRRemoteConfigFetchAndActivateStatus status, NSError * _Nullable error) {
        if (error) {
            NSLog(@"Error al obtener Remote Config: %@", error.localizedDescription);
        } else {
            NSLog(@"Remote Config actualizado correctamente.");
        }
    }];
}

Variant GodotFirebaseRemoteConfig::get_remote_config_value(String key) {
    // Obtiene la representación del valor de Remote Config con la clave dada
    FIRRemoteConfigValue *config_value = [[FIRRemoteConfig remoteConfig] configValueForKey:[NSString stringWithUTF8String:key.utf8().get_data()]];

    if (!config_value) {
        NSLog(@"[RemoteConfig Plugin]: Clave no encontrada: %@", [NSString stringWithUTF8String:key.utf8().get_data()]);
        return Variant(); // Devuelve un valor nulo si no existe la clave
    }

    // Detecta el tipo de datos y convierte el valor a un tipo Variant compatible
    if (config_value.stringValue) {
        // Intenta convertirlo a un string si es válido
        NSString *value = config_value.stringValue;
        return Variant(String(value.UTF8String));
    } else if (config_value.numberValue) {
        // Revisa si es un valor numérico
        NSNumber *value = config_value.numberValue;
        return Variant(value.doubleValue); // Devuelve como número flotante
    } else if ([config_value JSONValue]) {
        // Revisa si es un JSON, parsiando el valor
        id json_value = [config_value JSONValue];
        NSError *error;
        NSData *json_data = [NSJSONSerialization dataWithJSONObject:json_value options:0 error:&error];
        if (!error) {
            NSString *json_string = [[NSString alloc] initWithData:json_data encoding:NSUTF8StringEncoding];
            return Variant(String(json_string.UTF8String)); // Devuelve el JSON como una cadena
        } else {
            NSLog(@"[RemoteConfig Plugin]: Error al procesar JSON para clave: %@", [NSString stringWithUTF8String:key.utf8().get_data()]);
            return Variant(); // Valor nulo si hubo error en la conversión de JSON
        }
    } else {
        // Intenta interpretarlo como un valor booleano si no es una cadena ni número ni JSON
        return Variant(config_value.boolValue);
    }
}


void GodotFirebaseRemoteConfig::_bind_methods() {
    ADD_SIGNAL(MethodInfo("remote_config_updated"));
    ADD_SIGNAL(MethodInfo("remote_config_fetch_failed", PropertyInfo(Variant::STRING, "error_message")));

    ClassDB::bind_method(D_METHOD("fetch_remote_config"), &GodotFirebaseRemoteConfig::fetch_remote_config);
    ClassDB::bind_method(D_METHOD("get_remote_config_value", "key"), &GodotFirebaseRemoteConfig::get_remote_config_value);
}
