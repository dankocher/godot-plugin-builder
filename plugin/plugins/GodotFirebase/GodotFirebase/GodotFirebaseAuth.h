#ifndef GODOT_FIREBASE_AUTH_H
#define GODOT_FIREBASE_AUTH_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


//#import <GodotFirebase-Swift.h>

#import <FirebaseCore/FirebaseCore.h>

#import <GoogleSignIn/GoogleSignIn.h>
#import <GoogleSignIn/GIDSignIn.h>
#import <FirebaseAuth/FirebaseAuth.h>
#import <FirebaseAuth/FirebaseAuth-Swift.h>


#include "core/object/class_db.h"

class GodotFirebaseAuth : public Object {
    GDCLASS(GodotFirebaseAuth, Object);

private:
    static GodotFirebaseAuth *instance;

protected:
    static void _bind_methods(); // Método protegido

public:
    static GodotFirebaseAuth *get_singleton(); // Método público para obtener el singleton

    // Métodos expuestos
    void sign_in_with_google();
    void sign_in_anonymously();
    void sign_in_with_email(const String &email, const String &password);
    void sign_out();
    Variant get_current_user();

    GodotFirebaseAuth();
    ~GodotFirebaseAuth();
};

#endif // GODOT_FIREBASE_AUTH_H
