package com.dilongdann.godotfirebase

import android.app.Activity
import android.util.Log
import com.google.firebase.functions.FirebaseFunctions
import com.google.firebase.functions.FirebaseFunctionsException
import org.godotengine.godot.Dictionary
import org.godotengine.godot.Godot
import org.godotengine.godot.plugin.GodotPlugin
import org.godotengine.godot.plugin.SignalInfo
import org.godotengine.godot.plugin.UsedByGodot


class GodotFirebaseFunctions(godot: Godot) : GodotPlugin(godot) {

    private val TAG = "GodotFirebaseFunctions"
    private val functions: FirebaseFunctions
    private val activity: Activity = godot.getActivity() as Activity

    init {
        functions = FirebaseFunctions.getInstance()
        // Opcional: Configura una región predeterminada para las funciones
//        functions.useEmulator("10.0.2.2", 5001) // Cambia esto si usas funciones locales/emulador
        Log.d("GodotFirebaseFunctions", "FirebaseFunctions Plugin initialized")
    }

    override fun getPluginName(): String {
        return "GodotFirebaseFunctions"
    }

    override fun getPluginSignals(): MutableSet<SignalInfo> {
        val signals = mutableSetOf<SignalInfo>()
        signals.add(SignalInfo("function_success", Dictionary::class.java)) // Señal para resultados exitosos
        signals.add(SignalInfo("function_failure", Dictionary::class.java)) // Señal para errores
        return signals
    }

    /**
     * Llama a una función de Firebase Functions.
     * @param name El nombre de la función a llamar.
     * @param params Un Dictionary con los parámetros para la función.
     * @param callback Opcional: etiqueta para identificar la respuesta en Godot.
     */

    @UsedByGodot
    fun useEmulator(ip_address: String = "10.0.0.1", port: Int = 5001) {
        functions.useEmulator(ip_address, port) // Cambia esto si usas funciones locales/emulador

    }

    @UsedByGodot
    fun call_function(name: String, parametersJson: String, callback: String) {

        // Convertir el JSON de entrada a un HashMap<String, Any>
//        val data: HashMap<String, HashMap<String, Any>> = try {
//            val jsonObject = org.jwson.JSONObject(parametersJson)
//            val innerMap = jsonToHashMap(jsonObject) // Convertir JSON a un HashMap
//            hashMapOf("data" to innerMap) // Envolverlo bajo "data"
//        } catch (e: Exception) {
//            Log.e("FirestoreDebug", "Error parsing query JSON: ${e.message}")
//            hashMapOf("data" to hashMapOf()) // Usar un hashMap vacío en caso de error
//        }

        val data = try {
            val jsonObject = org.json.JSONObject(parametersJson)
            jsonToMap(jsonObject)
        } catch (e: Exception) {
            Log.e("FirestoreDebug", "Error parsing query JSON: ${e.message}")
            emptyMap<String, Any>()
        }

//        val data = convertDictionaryToMap(queryParameters) // Convierte el diccionario de Godot a un mapa de Java

        Log.d(TAG, name)
        Log.d(TAG, data.toString())


        functions.getHttpsCallable(name)
            .call(data)
            .addOnSuccessListener { result ->

                try {
                    val data = result.getData() // Obtén los datos de la función
                    Log.d(TAG, "Data result: $data")

                    // Verifica si data es un tipo válido (HashMap en este caso)
                    if (data is HashMap<*, *>) {
                        // Convierte data a un Dictionary compatible con Godot
                        val godotCompatibleData = convertToGodotType(data) as Dictionary

                        // Emite la señal con el Dictionary compatible
                        emitSignal("function_success", createSignalData(true, godotCompatibleData, callback))
                    } else {
                        // Manejo de error en caso de que el dato no sea un HashMap
                        val errorData = Dictionary()
                        errorData["error"] = "Data is not a HashMap but ${data?.javaClass}"
                        emitSignal("function_failure", createSignalData(false, errorData, callback))
                    }
                } catch (e: Exception) {
                    Log.e(TAG, "Error processing function result: ${e.message}")
                    val errorData = Dictionary()
                    errorData["error"] = e.message
                    emitSignal("function_failure", createSignalData(false, errorData, callback))
                }
            }
            .addOnFailureListener { exception ->

                if (exception is FirebaseFunctionsException) {
                    Log.e("GodotFirebaseFunctions", "Error Código: ${exception.code}")
                    Log.e("GodotFirebaseFunctions", "Error Detalles: ${exception.details}")
                }
                Log.e("GodotFirebaseFunctions", "Function call failed: ${exception.message}")


                Log.e("GodotFirebaseFunctions", "Function call failed: ${exception.message}")
                val errorMessage = if (exception is FirebaseFunctionsException) {
                    exception.details as? String ?: exception.message ?: "Unknown Firebase Function error"
                } else {
                    exception.message
                }
                val data = Dictionary()
                data["error"] = errorMessage
                emitSignal("function_failure", createSignalData(false, data, callback))
            }

    }
    private fun convertToGodotType(value: Any?): Any? {
        return when (value) {
            is HashMap<*, *> -> { // Si es un HashMap, conviértelo a un Dictionary
                val dictionary = Dictionary() // Asumiendo que esta clase está disponible
                value.forEach { (key, mapValue) ->
                    dictionary[key as String] = convertToGodotType(mapValue) // Conversión recursiva
                }
                dictionary
            }
            is List<*> -> { // Si es una List, conviértela a un MutableList (Array análogo en Kotlin)
                val list = mutableListOf<Any?>()
                value.forEach { item ->
                    list.add(convertToGodotType(item)) // Conversión recursiva para los elementos de la lista
                }
                list // Retorna la lista como un tipo compatible
            }
            else -> value // Otros tipos, como String, Int, Boolean, se devuelven tal cual
        }
    }

    private fun jsonToMap(jsonObject: org.json.JSONObject): Map<String, Any> {
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

    private fun jsonToList(jsonArray: org.json.JSONArray): List<Any> {
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

    private fun createSignalData(success: Boolean, data: Any, callback: String): Dictionary {
        val signalData = Dictionary()
        signalData["success"] = success
        signalData["data"] = data
        signalData["callback"] = callback
        return signalData
    }
}
