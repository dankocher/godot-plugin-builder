#import "GodotFirebaseFirestore.h"

GodotFirebaseFirestore *GodotFirebaseFirestore::instance = NULL;

GodotFirebaseFirestore::GodotFirebaseFirestore() {
    ERR_FAIL_COND(instance != NULL);
    instance = this;
}

GodotFirebaseFirestore::~GodotFirebaseFirestore() {
    if (instance == this) {
        instance = NULL;
    }
}

GodotFirebaseFirestore *GodotFirebaseFirestore::get_singleton() {
    return instance;
}

void GodotFirebaseFirestore::_bind_methods() {
    // CRUD
    ClassDB::bind_method(D_METHOD("add_document", "collection", "data", "callback"), &GodotFirebaseFirestore::add_document);
    ClassDB::bind_method(D_METHOD("get_document", "collection", "document_id", "callback"), &GodotFirebaseFirestore::get_document);
    ClassDB::bind_method(D_METHOD("update_document", "collection", "document_id", "data", "callback"), &GodotFirebaseFirestore::update_document);
    ClassDB::bind_method(D_METHOD("delete_document", "collection", "document_id", "callback"), &GodotFirebaseFirestore::delete_document);

    // Consultas avanzadas
    ClassDB::bind_method(D_METHOD("query_documents", "collection", "query_parameters", "callback"), &GodotFirebaseFirestore::query_documents);
}

/**
 * Método para agregar un documento a una colección.
 */
void GodotFirebaseFirestore::add_document(String collection, Dictionary data, Callable callback) {
    NSMutableDictionary *firebaseData = [NSMutableDictionary dictionary];
    Array keys = data.keys();

    for (int i = 0; i < keys.size(); i++) {
        String key = keys[i];
        Variant value = data[key];
        NSString *objcKey = [NSString stringWithUTF8String:key.utf8().get_data()];

        // Conversión de tipos compatibles
        if (value.get_type() == Variant::Type::STRING) {
            firebaseData[objcKey] = [NSString stringWithUTF8String:value.operator String().utf8().get_data()];
        } else if (value.get_type() == Variant::Type::INT) {
            firebaseData[objcKey] = @(int(value));
        } else if (value.get_type() == Variant::Type::FLOAT) {
            firebaseData[objcKey] = @(real_t(value));
        } else if (value.get_type() == Variant::Type::BOOL) {
            firebaseData[objcKey] = @(bool(value));
        }
    }

    NSString *objcCollection = [NSString stringWithUTF8String:collection.utf8().get_data()];
    FIRCollectionReference *collectionRef = [[FIRFirestore firestore] collectionWithPath:objcCollection];
    [collectionRef addDocumentWithData:firebaseData completion:^(NSError * _Nullable error) {
        if (error) {
//             call_deferred(callback, Array::make(false, String(error.localizedDescription.UTF8String)));
            Array args;
            args.append(false); // Agregamos "false" como primer argumento
            args.append(String(error.localizedDescription.UTF8String)); // Añadimos el error como segundo argumento
            callback.call_deferred(args);

        } else {
        
            Array args;
            args.append(true); // Suponiendo que el primer argumento indica éxito
            callback.call_deferred(args);

//             call_deferred(callback, Array::make(true));
        }
    }];
}

/**
 * Obtiene un documento por su ID.
 */
void GodotFirebaseFirestore::get_document(String collection, String document_id, Callable callback) {
    NSString *objcCollection = [NSString stringWithUTF8String:collection.utf8().get_data()];
    NSString *objcDocumentID = [NSString stringWithUTF8String:document_id.utf8().get_data()];

    FIRDocumentReference *docRef = [[[FIRFirestore firestore] collectionWithPath:objcCollection] documentWithPath:objcDocumentID];
    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (snapshot.exists) {
            // Convertir datos a Dictionary de Godot
            Dictionary result;
            NSDictionary *data = snapshot.data;
            for (NSString *key in data.allKeys) {
                result[String(key.UTF8String)] = Variant(data[key]);
            }
            Array args;
            args.append(true);
            args.append(result);
            callback.call_deferred(args);
//            call_deferred(callback, Array::make(true, result));
        } else {
            Array args;
            args.append(false);
            args.append(String(error.localizedDescription.UTF8String));
            callback.call_deferred(args);
//            call_deferred(callback, Array::make(false, String(error.localizedDescription.UTF8String)));
        }
    }];
}

/**
 * Actualiza un documento específico.
 */
void GodotFirebaseFirestore::update_document(String collection, String document_id, Dictionary data, Callable callback) {
    NSMutableDictionary *firebaseData = [NSMutableDictionary dictionary];
    Array keys = data.keys();

    for (int i = 0; i < keys.size(); i++) {
        String key = keys[i];
        Variant value = data[key];
        NSString *objcKey = [NSString stringWithUTF8String:key.utf8().get_data()];

        if (value.get_type() == Variant::Type::STRING) {
            firebaseData[objcKey] = [NSString stringWithUTF8String:value.operator String().utf8().get_data()];
        } else if (value.get_type() == Variant::Type::INT) {
            firebaseData[objcKey] = @(int(value));
        }
    }
    
    NSString *objcCollection = [NSString stringWithUTF8String:collection.utf8().get_data()];
    NSString *objcDocumentID = [NSString stringWithUTF8String:document_id.utf8().get_data()];
    FIRDocumentReference *docRef = [[[FIRFirestore firestore] collectionWithPath:objcCollection] documentWithPath:objcDocumentID];

    [docRef updateData:firebaseData completion:^(NSError * _Nullable error) {
        if (error) {
            Array args;
            args.append(false);
            args.append(String(error.localizedDescription.UTF8String));
            callback.call_deferred(args);
        } else {
            Array args;
            args.append(true);
            callback.call_deferred(args);
        }
    }];
}


void GodotFirebaseFirestore::delete_document(String collection, String document_id, Callable callback) {
    NSString *objcCollection = [NSString stringWithUTF8String:collection.utf8().get_data()];
    NSString *objcDocumentID = [NSString stringWithUTF8String:document_id.utf8().get_data()];

    FIRDocumentReference *docRef = [[[FIRFirestore firestore] collectionWithPath:objcCollection] documentWithPath:objcDocumentID];
    [docRef deleteDocumentWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            Array args;
            args.append(false);
            args.append(String(error.localizedDescription.UTF8String));
            callback.call_deferred(args);
        } else {
            Array args;
            args.append(true);
            callback.call_deferred(args);
        }
    }];
}


void GodotFirebaseFirestore::query_documents(String collection, Dictionary query_parameters, Callable callback) {
    NSString *objcCollection = [NSString stringWithUTF8String:collection.utf8().get_data()];
    FIRCollectionReference *collectionRef = [[FIRFirestore firestore] collectionWithPath:objcCollection];
    FIRQuery *query = collectionRef;

    // Procesamos las cláusulas `where`
    if (query_parameters.has("where")) {
        Array where_clauses = query_parameters["where"];
        for (int i = 0; i < where_clauses.size(); i++) {
            Dictionary clause = where_clauses[i];
            if (clause.has("field") && clause.has("operator") && clause.has("value")) {
                String field = clause["field"];
                String op = clause["operator"];
                Variant value = clause["value"];

                NSString *objcField = [NSString stringWithUTF8String:field.utf8().get_data()];

                // Verificamos el operador y construimos la consulta
                if (op == "==") {
                    query = [query queryWhereField:objcField isEqualTo:convert_variant_to_nsobject(value)];
                } else if (op == ">") {
                    query = [query queryWhereField:objcField isGreaterThan:convert_variant_to_nsobject(value)];
                } else if (op == ">=") {
                    query = [query queryWhereField:objcField isGreaterThanOrEqualTo:convert_variant_to_nsobject(value)];
                } else if (op == "<") {
                    query = [query queryWhereField:objcField isLessThan:convert_variant_to_nsobject(value)];
                } else if (op == "<=") {
                    query = [query queryWhereField:objcField isLessThanOrEqualTo:convert_variant_to_nsobject(value)];
                } else {
                    NSLog(@"Unsupported operator: %@", [NSString stringWithUTF8String:op.utf8().get_data()]);
                }
            }
        }
    }

    // Procesamos las cláusulas `orderBy`
    if (query_parameters.has("orderBy")) {
        Array order_clauses = query_parameters["orderBy"];
        for (int i = 0; i < order_clauses.size(); i++) {
            Dictionary clause = order_clauses[i];
            if (clause.has("field") && clause.has("direction")) {
                String field = clause["field"];
                String direction = clause["direction"];
                NSString *objcField = [NSString stringWithUTF8String:field.utf8().get_data()];

                if (direction == "asc") {
                    query = [query queryOrderedByField:objcField];
                } else if (direction == "desc") {
                    query = [query queryOrderedByField:objcField descending:YES];
                }
            }
        }
    }

    // Procesamos `limit`
    if (query_parameters.has("limit")) {
        int limit_value = int(query_parameters["limit"]);
        query = [query queryLimitedTo:limit_value];
    }

    // Procesamos `startAt`
    if (query_parameters.has("startAt")) {
        Variant start_value = query_parameters["startAt"];
        query = [query queryStartingAtValues:@[convert_variant_to_nsobject(start_value)]];
    }

    // Procesamos `endAt`
    if (query_parameters.has("endAt")) {
        Variant end_value = query_parameters["endAt"];
        query = [query queryEndingAtValues:@[convert_variant_to_nsobject(end_value)]];
    }

    // Ejecutamos la consulta
    [query getDocumentsWithCompletion:^(FIRQuerySnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (error) {
            // En caso de error, devolvemos el mensaje de error mediante el callback
            Array args;
            args.append(false);
            args.append(String(error.localizedDescription.UTF8String));
            callback.call_deferred(args);
        } else {
            // Procesamos los documentos y devolvemos el resultado como un Array de Dictionaries
            Array results;
            for (FIRDocumentSnapshot *document in snapshot.documents) {
                Dictionary doc_data;
                NSDictionary *data = document.data;
                for (NSString *key in data.allKeys) {
                    doc_data[String(key.UTF8String)] = nsobject_to_variant(data[key]);
                }
                results.push_back(doc_data);
            }
            Array args;
            args.append(true);
            args.append(results);
            callback.call_deferred(args);
        }
    }];
}
/**
 * Helper: Convierte un `Variant` de Godot a un `NSObject` compatible con Firebase Firestore.
 */
NSObject *GodotFirebaseFirestore::convert_variant_to_nsobject(Variant value) {
    if (value.get_type() == Variant::Type::STRING) {
        return [NSString stringWithUTF8String:value.operator String().utf8().get_data()];
    } else if (value.get_type() == Variant::Type::INT) {
        return @(int(value));
    } else if (value.get_type() == Variant::Type::FLOAT) {
        return @(real_t(value));
    } else if (value.get_type() == Variant::Type::BOOL) {
        return @(bool(value));
    } else {
        NSLog(@"Unsupported Variant type for conversion");
        return nil;
    }
}

/**
 * Helper: Convierte un `NSObject` de Firebase Firestore a un `Variant` de Godot.
 */
Variant GodotFirebaseFirestore::nsobject_to_variant(NSObject *object) {
    if ([object isKindOfClass:[NSString class]]) {
        return Variant(String([(NSString *)object UTF8String]));
    } else if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *num = (NSNumber *)object;
        // Determinamos si es entero, booleano, o flotante
        const char *type = [num objCType];
        if (strcmp(type, @encode(BOOL)) == 0) {
            return Variant(bool([num boolValue]));
        } else if (strcmp(type, @encode(int)) == 0 || strcmp(type, @encode(NSInteger)) == 0) {
            return Variant(int([num intValue]));
        } else {
            return Variant(real_t([num floatValue]));
        }
    } else {
        NSLog(@"Unsupported NSObject type for conversion");
        return Variant();
    }
}
