#ifndef GODOT_FIREBASE_AUTH_H
#define GODOT_FIREBASE_AUTH_H

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <FirebaseCore/FirebaseCore.h>
#import <GoogleSignIn/GoogleSignIn.h>
#import <FirebaseAuth/FirebaseAuth-Swift.h>


#include "core/object/class_db.h"

class GodotFirebaseAuth : public Object {
    GDCLASS(GodotFirebaseAuth, Object);

private:
    static GodotFirebaseAuth *instance;
    
protected:
    static void _bind_methods(); // Método protegido
    
    // Declaración de métodos auxiliares
    UIViewController* get_root_view_controller() const; // Método para obtener el RootViewController
    Dictionary create_user_data(FIRUser *user) const;


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
