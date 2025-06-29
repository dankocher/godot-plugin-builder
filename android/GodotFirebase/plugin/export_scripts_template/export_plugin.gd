@tool
extends EditorPlugin

# A class member to hold the editor export plugin during its lifecycle.
var export_plugin : AndroidExportPlugin

func _enter_tree():
	# Initialization of the plugin goes here.
	export_plugin = AndroidExportPlugin.new()
	add_export_plugin(export_plugin)


func _exit_tree():
	# Clean-up of the plugin goes here.
	remove_export_plugin(export_plugin)
	export_plugin = null


class AndroidExportPlugin extends EditorExportPlugin:
	# TODO: Update to your plugin's name.
	var _plugin_name = "GodotFirebase"

	func _supports_platform(platform):
		if platform is EditorExportPlatformAndroid:
			return true
		return false

	func _get_android_libraries(platform, debug):
		if debug:
			return PackedStringArray([_plugin_name + "/bin/debug/" + _plugin_name + "-debug.aar"])
		else:
			return PackedStringArray([_plugin_name + "/bin/release/" + _plugin_name + "-release.aar"])

	func _get_android_dependencies(platform, debug):
		# Define las dependencias remotas que utilizará el plugin.
		# Estas dependencias están basadas en las especificadas en Gradle.

		# Dependencias comunes para ambas configuraciones
		var dependencies = PackedStringArray([
			"androidx.core:core-ktx:1.15.0",
			"androidx.appcompat:appcompat:1.7.0",
			"com.google.firebase:firebase-bom:33.9.0",
			"com.google.firebase:firebase-analytics",
			"com.google.firebase:firebase-crashlytics",
			"com.google.firebase:firebase-auth",
			"com.google.firebase:firebase-config-ktx",
			"com.google.firebase:firebase-firestore-ktx",
			"com.google.firebase:firebase-functions-ktx",
			"com.google.android.gms:play-services-auth:21.3.0",
			"com.google.android.gms:play-services-measurement-api:22.2.0",
			"androidx.credentials:credentials:1.3.0",
			"androidx.credentials:credentials-play-services-auth:1.3.0",
			"com.google.android.libraries.identity.googleid:googleid:1.1.1"
		])

		if debug:
			# Aquí puedes agregar dependencias específicas para debug si son necesarias.
			# En este caso, son las mismas para ambas configuraciones.
			return dependencies
		else:
			return dependencies

	func _get_name():
		return _plugin_name
