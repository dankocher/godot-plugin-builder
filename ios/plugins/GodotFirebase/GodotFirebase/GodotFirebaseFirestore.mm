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
    ADD_SIGNAL(MethodInfo("document_added", PropertyInfo(Variant::BOOL, "success"), PropertyInfo(Variant::STRING, "error_message")));
    ADD_SIGNAL(MethodInfo("document_retrieved", PropertyInfo(Variant::BOOL, "success"), PropertyInfo(Variant::DICTIONARY, "result")));
    ADD_SIGNAL(MethodInfo("document_updated", PropertyInfo(Variant::BOOL, "success"), PropertyInfo(Variant::STRING, "error_message")));
    ADD_SIGNAL(MethodInfo("document_deleted", PropertyInfo(Variant::BOOL, "success"), PropertyInfo(Variant::STRING, "error_message")));
    ADD_SIGNAL(MethodInfo("query_executed", PropertyInfo(Variant::BOOL, "success"), PropertyInfo(Variant::ARRAY, "results")));

    ClassDB::bind_method(D_METHOD("get_document", "collection", "document_id", "callback"), &GodotFirebaseFirestore::get_document);
    ClassDB::bind_method(D_METHOD("add_document", "collection", "data", "callback"), &GodotFirebaseFirestore::add_document);
    ClassDB::bind_method(D_METHOD("set_document", "collection", "document_id", "data", "callback"), &GodotFirebaseFirestore::set_document);
    ClassDB::bind_method(D_METHOD("update_document", "collection", "document_id", "data", "callback"), &GodotFirebaseFirestore::update_document);
    ClassDB::bind_method(D_METHOD("delete_document", "collection", "document_id", "callback"), &GodotFirebaseFirestore::delete_document);
    ClassDB::bind_method(D_METHOD("query_documents", "collection", "query_parameters", "callback"), &GodotFirebaseFirestore::query_documents);
}


/**
 * Obtiene un documento por su ID.
 */
void GodotFirebaseFirestore::get_document(String collection, String document_id, String callback) {
    NSString *objcCollection = [NSString stringWithUTF8String:collection.utf8().get_data()];
    NSString *objcDocumentID = [NSString stringWithUTF8String:document_id.utf8().get_data()];

    NSLog(@"[FirebaseFirestore] get_document %@ ", [NSString stringWithUTF8String:document_id.utf8()]);

    FIRDocumentReference *docRef = [[[FIRFirestore firestore] collectionWithPath:objcCollection] documentWithPath:objcDocumentID];
    [docRef getDocumentWithCompletion:^(FIRDocumentSnapshot * _Nullable snapshot, NSError * _Nullable error) {
        if (snapshot.exists) {
            Dictionary result;
            NSDictionary *data = snapshot.data;
            for (NSString *key in data.allKeys) {
                NSObject *value = data[key];
                NSLog(@"[DEBUG] Key: %@, Class: %@, Value: %@", key, [value class], value);
                result[String(key.UTF8String)] = nsobject_to_variant(value);

            }
            emit_signal("document_retrieved", true, result, callback);
        } else {
            emit_signal("document_retrieved", false, Dictionary(), callback);
        }
    }];
}

/**
 * Método para agregar un documento a una colección.
 */
void GodotFirebaseFirestore::add_document(String collection, Dictionary data, String callback) {
    NSMutableDictionary *firebaseData = [NSMutableDictionary dictionary];
    Array keys = data.keys();

    for (int i = 0; i < keys.size(); i++) {
        String key = keys[i];
        Variant value = data[key];
        NSString *objcKey = [NSString stringWithUTF8String:key.utf8().get_data()];

        firebaseData[objcKey] = convert_variant_to_nsobject(value);
    }
    firebaseData[@"created_at"] = [FIRFieldValue fieldValueForServerTimestamp];

    NSString *objcCollection = [NSString stringWithUTF8String:collection.utf8().get_data()];
    FIRCollectionReference *collectionRef = [[FIRFirestore firestore] collectionWithPath:objcCollection];
    [collectionRef addDocumentWithData:firebaseData completion:^(NSError * _Nullable error) {
        if (error) {
            emit_signal("document_added", false, String(error.localizedDescription.UTF8String), callback);
        } else {
            emit_signal("document_added", true, "");
        }
    }];
}

void GodotFirebaseFirestore::set_document(String collection, String document_id, Dictionary data, String callback) {
    NSMutableDictionary *firebaseData = [NSMutableDictionary dictionary];
    Array keys = data.keys();

    for (int i = 0; i < keys.size(); i++) {
        String key = keys[i];
        Variant value = data[key];
        NSString *objcKey = [NSString stringWithUTF8String:key.utf8().get_data()];

        firebaseData[objcKey] = convert_variant_to_nsobject(value);
    }
    firebaseData[@"created_at"] = [FIRFieldValue fieldValueForServerTimestamp];

    NSString *objcCollection = [NSString stringWithUTF8String:collection.utf8().get_data()];
    NSString *objcID = [NSString stringWithUTF8String:document_id.utf8().get_data()];
    FIRDocumentReference *docRef = [[[FIRFirestore firestore] collectionWithPath:objcCollection] documentWithPath:objcID];

    // Establecemos el documento con los datos proporcionados
    [docRef setData:firebaseData completion:^(NSError * _Nullable error) {
        if (error) {
            // Emitimos una señal de error
            emit_signal("document_added", false, String(error.localizedDescription.UTF8String), callback);
        } else {
            // Emitimos una señal de éxito
            emit_signal("document_added", true, "", callback);
        }
    }];
}

/**
 * Actualiza un documento específico.
 */
void GodotFirebaseFirestore::update_document(String collection, String document_id, Dictionary data, String callback) {
    NSMutableDictionary *firebaseData = [NSMutableDictionary dictionary];
    Array keys = data.keys();

    for (int i = 0; i < keys.size(); i++) {
        String key = keys[i];
        Variant value = data[key];
        NSString *objcKey = [NSString stringWithUTF8String:key.utf8().get_data()];

        firebaseData[objcKey] = convert_variant_to_nsobject(value);
    }
    firebaseData[@"updated_at"] = [FIRFieldValue fieldValueForServerTimestamp];

    NSString *objcCollection = [NSString stringWithUTF8String:collection.utf8().get_data()];
    NSString *objcDocumentID = [NSString stringWithUTF8String:document_id.utf8().get_data()];
    FIRDocumentReference *docRef = [[[FIRFirestore firestore] collectionWithPath:objcCollection] documentWithPath:objcDocumentID];

    [docRef updateData:firebaseData completion:^(NSError * _Nullable error) {
        if (error) {
            // Emitimos la señal con error
            emit_signal("document_updated", false, String(error.localizedDescription.UTF8String), callback);
        } else {
            // Emitimos la señal con éxito
            emit_signal("document_updated", true, "");
        }
    }];
}


void GodotFirebaseFirestore::delete_document(String collection, String document_id, String callback) {
    NSString *objcCollection = [NSString stringWithUTF8String:collection.utf8().get_data()];
    NSString *objcDocumentID = [NSString stringWithUTF8String:document_id.utf8().get_data()];

    // Obtener referencia al documento a eliminar
    FIRDocumentReference *docRef = [[[FIRFirestore firestore] collectionWithPath:objcCollection] documentWithPath:objcDocumentID];

    // Ejecutar la operación de eliminación
    [docRef deleteDocumentWithCompletion:^(NSError * _Nullable error) {
        if (error) {
            // Emitir señal en caso de error
            emit_signal("document_deleted", false, String(error.localizedDescription.UTF8String), callback);
        } else {
            // Emitir señal en caso de éxito
            emit_signal("document_deleted", true, "");
        }
    }];
}


void GodotFirebaseFirestore::query_documents(String collection, Dictionary query_parameters, String callback) {
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
            // Emisión de la señal en caso de error
            emit_signal("query_executed", false, Array(), String(error.localizedDescription.UTF8String), callback);
        } else {
            // Procesamos los documentos y los devolvemos como un Array de Dictionaries
            Array results;
            for (FIRDocumentSnapshot *document in snapshot.documents) {
                Dictionary doc_data;
                NSDictionary *data = document.data;
                for (NSString *key in data.allKeys) {
                    doc_data[String(key.UTF8String)] = nsobject_to_variant(data[key]);
                }
                results.push_back(doc_data);
            }
            // Emisión de la señal en caso de éxito
            emit_signal("query_executed", true, results, String());
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
        // Si el objeto es una cadena (NSString)
        return Variant(String([(NSString *)object UTF8String]));

    } else if ([object isKindOfClass:[NSNumber class]]) {
        // Si el objeto es un número o booleano (NSNumber)
        NSNumber *num = (NSNumber *)object;
        const char *type = [num objCType];

        // Verificar si es BOOLEANO (y no un número 0 o 1)
        if (strcmp(type, @encode(BOOL)) == 0) {
            return Variant(bool([num boolValue])); // Es un booleano
        }

        // Si no es BOOL, se trata como un número:
        if (strcmp(type, @encode(int)) == 0 || strcmp(type, @encode(NSInteger)) == 0 ||
            strcmp(type, @encode(long)) == 0 || strcmp(type, @encode(long long)) == 0) {
            // Números enteros
            return Variant(int([num intValue]));
        } else if (strcmp(type, @encode(unsigned int)) == 0 || strcmp(type, @encode(unsigned long)) == 0 ||
                   strcmp(type, @encode(unsigned long long)) == 0) {
            // Números enteros sin signo
            return Variant(unsigned([num unsignedLongValue]));
        } else if (strcmp(type, @encode(float)) == 0 || strcmp(type, @encode(double)) == 0) {
            // Números flotantes
            return Variant(real_t([num doubleValue]));
        } else {
            // En caso de duda, lo tratamos como un flotante genérico
            NSLog(@"[WARN] Unknown NSNumber type encountered, fallback to float.");
            return Variant(real_t([num doubleValue]));
        }

    } else if ([object isKindOfClass:[NSNull class]]) {
        // Si el valor es nulo (NSNull)
        return Variant();

    } else {
        // Si el tipo de objeto no está soportado
        NSLog(@"[ERROR] Unsupported NSObject type for conversion: %@", [object class]);
        return Variant(); // Retorna un Variant vacío
    }
}
