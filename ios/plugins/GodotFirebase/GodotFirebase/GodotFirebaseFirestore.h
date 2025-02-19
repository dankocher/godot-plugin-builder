#ifndef GODOT_FIREBASE_FIRESTORE_H
#define GODOT_FIREBASE_FIRESTORE_H

#import <Foundation/Foundation.h>
#import <FirebaseFirestore/FirebaseFirestore.h>
#include "core/object/class_db.h"

class GodotFirebaseFirestore : public Object {
    GDCLASS(GodotFirebaseFirestore, Object);

private:
    static GodotFirebaseFirestore *instance;

protected:
    static void _bind_methods();

    // Declaración de métodos auxiliares
    NSObject *convert_variant_to_nsobject(Variant value);
    Variant nsobject_to_variant(NSObject *object);

public:
    static GodotFirebaseFirestore *get_singleton();

    // Operaciones CRUD
    void get_document(String collection, String document_id, String callback);
    void add_document(String collection, Dictionary data, String callback);
    void set_document(String collection, String document_id, Dictionary data, String callback);
    void update_document(String collection, String document_id, Dictionary data, String callback);
    void delete_document(String collection, String document_id, String callback);

    // Consultas avanzadas
    void query_documents(String collection, Dictionary query_parameters, String callback);

    GodotFirebaseFirestore();
    ~GodotFirebaseFirestore();
};

#endif
