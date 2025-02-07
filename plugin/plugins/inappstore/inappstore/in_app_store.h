//
//  in_app_store.h
//  in_app_store
//
//  Created by Daniel Roke on 24.11.24.
//

#ifndef IN_APP_STORE_H
#define IN_APP_STORE_H

#include "core/object/class_db.h"
#include "core/object/object.h"

#ifdef __OBJC__
@class GodotProductsDelegate;
@class GodotTransactionsObserver;

typedef GodotProductsDelegate InAppStoreProductDelegate;
typedef GodotTransactionsObserver InAppStoreTransactionObserver;
#else
typedef void InAppStoreProductDelegate;
typedef void InAppStoreTransactionObserver;
#endif

class InAppStore : public Object {

    GDCLASS(InAppStore, Object);

    static InAppStore *instance;
    static void _bind_methods();

    List<Variant> pending_events;

    InAppStoreProductDelegate *products_request_delegate;
    InAppStoreTransactionObserver *transactions_observer;

public:
    Error request_product_info(Dictionary p_params);
    Error restore_purchases();
    Error purchase(Dictionary p_params);

    int get_pending_event_count();
    Variant pop_pending_event();
    void finish_transaction(String product_id);
    void set_auto_finish_transaction(bool b);

    void _post_event(Variant p_event);
    void _record_purchase(String product_id);

    static InAppStore *get_singleton();

    InAppStore();
    ~InAppStore();
};

#endif
