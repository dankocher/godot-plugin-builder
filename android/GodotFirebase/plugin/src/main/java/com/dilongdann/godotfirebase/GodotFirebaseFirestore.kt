package com.dilongdann.godotfirebase

import android.app.Activity
import android.util.Log
import com.google.firebase.firestore.FirebaseFirestore
import com.google.firebase.firestore.Query
import com.google.firebase.firestore.CollectionReference
import org.godotengine.godot.Dictionary
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot

class GodotFirebaseFirestore(godot: Godot) : GodotPlugin(godot) {

    private val TAG = "GodotFirebaseFirestore"
    private val firestore: FirebaseFirestore
    private val activity: Activity = godot.getActivity() as Activity

    init {
        firestore = FirebaseFirestore.getInstance()
    }

    override fun getPluginName(): String {
        return "GodotFirebaseFirestore"
    }

    override fun getPluginSignals(): MutableSet<SignalInfo> {
        val signals = mutableSetOf<SignalInfo>()

//        signals.add(SignalInfo("document_added", Boolean::class.java, String::class.java, String::class.java))
//        signals.add(SignalInfo("document_retrieved", Boolean::class.java, Dictionary::class.java, String::class.java))
//        signals.add(SignalInfo("document_updated", Boolean::class.java, String::class.java, String::class.java))
//        signals.add(SignalInfo("document_deleted", Boolean::class.java, String::class.java, String::class.java))
//        signals.add(SignalInfo("query_executed", Boolean::class.java, ArrayList::class.java, String::class.java))

        signals.add(SignalInfo("document_added", Dictionary::class.java))
        signals.add(SignalInfo("document_retrieved", Dictionary::class.java))
        signals.add(SignalInfo("document_updated", Dictionary::class.java))
        signals.add(SignalInfo("document_deleted", Dictionary::class.java))
        signals.add(SignalInfo("query_executed", Dictionary::class.java))

        return signals
    }

     @UsedByGodot
     fun add_document(collection: String, data: Dictionary, callback: String) {
         val documentData = convertDictionaryToMap(data).toMutableMap()
         documentData["created_at"] = com.google.firebase.firestore.FieldValue.serverTimestamp() // Agregamos el campo updated_at
         firestore.collection(collection)
             .add(documentData)
             .addOnSuccessListener {
                 emitSignal("document_added", signalData(true, "", callback))
             }
             .addOnFailureListener { e ->
                 emitSignal("document_added", signalData(false, e.message ?: "Unknown error", callback))
             }
     }

     @UsedByGodot
     fun set_document(collection: String, documentId: String, data: Dictionary, callback: String) {
         val documentData = convertDictionaryToMap(data).toMutableMap()
         documentData["created_at"] = com.google.firebase.firestore.FieldValue.serverTimestamp() // Agregamos el campo updated_at
         firestore.collection(collection)
             .document(documentId)
             .set(documentData)
             .addOnSuccessListener {
                 emitSignal("document_updated", signalData(true, "", callback))
             }
             .addOnFailureListener { e ->
                 emitSignal("document_updated", signalData(false, e.message ?: "Unknown error", callback))
             }
     }

     @UsedByGodot
     fun get_document(collection: String, documentId: String, callback: String) {
         firestore.collection(collection)
             .document(documentId)
             .get()
             .addOnSuccessListener { document ->
                 if (document.exists()) {
                     val data = document.data ?: emptyMap<String, Any>()
                     emitSignal("document_retrieved", signalData(true, convertMapToDictionary(data), callback))
                 } else {
                     emitSignal("document_retrieved", signalData(false, Dictionary(), callback))
                 }
             }
             .addOnFailureListener {
                 emitSignal("document_retrieved", signalData(false, Dictionary(), callback))
             }
     }

    @UsedByGodot
    fun update_document(collection: String, documentId: String, data: Dictionary, callback: String) {
        val documentData = convertDictionaryToMap(data).toMutableMap() // Convertimos el Dictionary a Map
        documentData["updated_at"] = com.google.firebase.firestore.FieldValue.serverTimestamp() // Agregamos el campo updated_at

        firestore.collection(collection)
            .document(documentId)
            .update(documentData)
            .addOnSuccessListener {
                emitSignal("document_updated", signalData(true, "", callback)) // Emitimos la señal de éxito
            }
            .addOnFailureListener { e ->
                emitSignal("document_updated", signalData(false, e.message ?: "Unknown error", callback)) // Emitimos la señal de error
            }
    }


     @UsedByGodot
     fun delete_document(collection: String, documentId: String, callback: String) {
         firestore.collection(collection)
             .document(documentId)
             .delete()
             .addOnSuccessListener {
                 emitSignal("document_deleted", signalData(true, "", callback))
             }
             .addOnFailureListener { e ->
                 emitSignal("document_deleted", signalData(false, e.message ?: "Unknown error", callback))
             }
     }

    @Suppress("UNCHECKED_CAST")
    fun safeCastToListOfMap(input: Any?): List<Map<String, Any>> {
        if (input !is List<*>) return emptyList()
        val list = mutableListOf<Map<String, Any>>()
        for (item in input) {
            if (item is Map<*, *>) {
                // Aquí hacemos cast seguro para claves y valores
                val map = item as? Map<String, Any> ?: continue
                list.add(map)
            }
        }
        return list
    }

    @UsedByGodot
    fun query_documents(collection: String, queryParametersJson: String, callback: String) {
        val firestore = FirebaseFirestore.getInstance()
        val collectionRef: CollectionReference = firestore.collection(collection)
        var queryBuilder: Query = collectionRef

        // Parsear JSON a Map usando org.json
        val queryParameters = try {
            val jsonObject = org.json.JSONObject(queryParametersJson)
            jsonToMap(jsonObject)
        } catch (e: Exception) {
            Log.e("FirestoreDebug", "Error parsing query JSON: ${e.message}")
            emptyMap<String, Any>()
        }

        // Ahora procesa como antes
        val whereClauses = safeCastToListOfMap(queryParameters["where"])
        for (clause in whereClauses) {
            val field = clause["field"] as? String
            val operator = clause["operator"] as? String
            val value = clause["value"]

            if (field != null && operator != null) {
                when (operator) {
                    "==" -> queryBuilder = queryBuilder.whereEqualTo(field, value ?: "")
                    ">" -> queryBuilder = queryBuilder.whereGreaterThan(field, value ?: "")
                    ">=" -> queryBuilder = queryBuilder.whereGreaterThanOrEqualTo(field, value ?: "")
                    "<" -> queryBuilder = queryBuilder.whereLessThan(field, value ?: "")
                    "<=" -> queryBuilder = queryBuilder.whereLessThanOrEqualTo(field, value ?: "")
                    else -> Log.w("FirestoreDebug", "Unsupported operator: $operator")
                }
            }
        }

        val orderClauses = safeCastToListOfMap(queryParameters["orderBy"])
        for (clause in orderClauses) {
            val field = clause["field"] as? String
            val direction = clause["direction"] as? String

            if (field != null) {
                queryBuilder = when (direction?.lowercase()) {
                    "asc" -> queryBuilder.orderBy(field, Query.Direction.ASCENDING)
                    "desc" -> queryBuilder.orderBy(field, Query.Direction.DESCENDING)
                    else -> queryBuilder.orderBy(field)
                }
            }
        }

        // Procesar límite
        val limitValue = (queryParameters["limit"] as? Int) ?: 0
        if (limitValue > 0) {
            queryBuilder = queryBuilder.limit(limitValue.toLong())
        }

        // startAt
        if (queryParameters.containsKey("startAt")) {
            val startValue = queryParameters["startAt"]
            if (startValue != null) {
                queryBuilder = queryBuilder.startAt(startValue)
            }
        }

        // endAt
        if (queryParameters.containsKey("endAt")) {
            val endValue = queryParameters["endAt"]
            if (endValue != null) {
                queryBuilder = queryBuilder.endAt(endValue)
            }
        }

        // Ejecutar query
        queryBuilder.get()
            .addOnSuccessListener { result ->
                val documents = ArrayList<Dictionary>()
                for (document in result) {
                    val docData = Dictionary()
                    for ((key, value) in document.data) {
                        docData[key] = value
                    }
                    documents.add(docData)
                }
                emitSignal("query_executed", signalData(true, documents, callback))
            }
            .addOnFailureListener { exception ->
                emitSignal("query_executed", signalData(false, exception.message ?: "", callback))
            }
    }

    fun jsonToMap(jsonObject: org.json.JSONObject): Map<String, Any> {
        val map = mutableMapOf<String, Any>()
        val keys = jsonObject.keys()
        while (keys.hasNext()) {
            val key = keys.next()
            var value = jsonObject.get(key)
            if (value is org.json.JSONObject) {
                value = jsonToMap(value)
            } else if (value is org.json.JSONArray) {
                value = jsonToList(value)
            }
            map[key] = value
        }
        return map
    }

    fun jsonToList(jsonArray: org.json.JSONArray): List<Any> {
        val list = mutableListOf<Any>()
        for (i in 0 until jsonArray.length()) {
            var value = jsonArray.get(i)
            if (value is org.json.JSONObject) {
                value = jsonToMap(value)
            } else if (value is org.json.JSONArray) {
                value = jsonToList(value)
            }
            list.add(value)
        }
        return list
    }

    private fun signalData(success: Boolean, result: Any, callback: String): Dictionary {
        val signalData = Dictionary()
        signalData["success"] = success
        signalData["result"] = result
        signalData["callback"] = callback
        return signalData
    }

    private fun convertDictionaryToMap(dictionary: Dictionary): Map<String, Any> {
        val map = HashMap<String, Any>()
        for (pair in dictionary) {
            map[pair.key as String] = pair.value as Any
        }
        return map
    }

    private fun convertMapToDictionary(map: Map<String, Any>): Dictionary {
        val dictionary = Dictionary()
        for ((key, value) in map) {
            dictionary[key] = value
        }
        return dictionary
    }
}
