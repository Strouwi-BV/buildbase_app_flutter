import FlutterMacOS
import Foundation

import flutter_local_notifications
import shared_preferences_foundation
import location

func RegisterGeneratedPlugins(registry: FlutterPluginRegistry) {
  FlutterLocalNotificationsPlugin.register(with: registry.registrar(forPlugin: "FlutterLocalNotificationsPlugin"))
  SharedPreferencesPlugin.register(with: registry.registrar(forPlugin: "SharedPreferencesPlugin"))
  LocationPlugin.register(with: registry.registrar(forPlugin: "LocationPlugin"))
}
