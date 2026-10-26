import Flutter
import UIKit
import UniformTypeIdentifiers

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "FolderPickerPlugin") {
      FolderPickerPlugin.register(with: registrar)
    }
  }
}

/// Channel "my_music/folder" used by lib/core/folder_access/folder_access_ios.dart.
/// Picks folders from the Files app and keeps access to them across launches
/// with security-scoped bookmarks. Access stays open while the app runs.
final class FolderPickerPlugin: NSObject, FlutterPlugin, UIDocumentPickerDelegate {
  private var pendingResult: FlutterResult?
  private var openURLs: [String: URL] = [:]

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "my_music/folder", binaryMessenger: registrar.messenger())
    let instance = FolderPickerPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? [String: Any]
    switch call.method {
    case "pickFolder":
      pickFolder(result)
    case "resolve":
      resolve(args?["bookmark"] as? String, result)
    case "release":
      if let path = args?["path"] as? String, let url = openURLs.removeValue(forKey: path) {
        url.stopAccessingSecurityScopedResource()
      }
      result(nil)
    case "requestDownload":
      if let path = args?["path"] as? String { requestDownload(path) }
      result(nil)
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  // MARK: pick

  private func pickFolder(_ result: @escaping FlutterResult) {
    if pendingResult != nil {
      result(FlutterError(code: "busy", message: "Picker already open", details: nil))
      return
    }
    guard let presenter = Self.topViewController() else {
      result(FlutterError(code: "no_ui", message: "No view controller to present from", details: nil))
      return
    }
    let picker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.folder])
    picker.delegate = self
    picker.allowsMultipleSelection = false
    pendingResult = result
    presenter.present(picker, animated: true)
  }

  func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
    guard let result = pendingResult else { return }
    pendingResult = nil
    guard let url = urls.first else {
      result(nil)
      return
    }
    let started = url.startAccessingSecurityScopedResource()
    do {
      let data = try url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil)
      if started { openURLs[url.path] = url }
      result(["bookmark": data.base64EncodedString(), "path": url.path, "name": url.lastPathComponent])
    } catch {
      if started { url.stopAccessingSecurityScopedResource() }
      result(FlutterError(code: "bookmark_failed", message: error.localizedDescription, details: nil))
    }
  }

  func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
    pendingResult?(nil)
    pendingResult = nil
  }

  // MARK: resolve

  private func resolve(_ base64: String?, _ result: FlutterResult) {
    guard let base64 = base64, let data = Data(base64Encoded: base64) else {
      result(FlutterError(code: "bad_bookmark", message: "Missing bookmark", details: nil))
      return
    }
    do {
      var stale = false
      let url = try URL(resolvingBookmarkData: data, options: [], relativeTo: nil, bookmarkDataIsStale: &stale)
      if openURLs[url.path] == nil, url.startAccessingSecurityScopedResource() {
        openURLs[url.path] = url
      }
      var map: [String: Any] = ["path": url.path]
      if stale, let fresh = try? url.bookmarkData(options: [], includingResourceValuesForKeys: nil, relativeTo: nil) {
        map["bookmark"] = fresh.base64EncodedString()
      }
      result(map)
    } catch {
      result(FlutterError(code: "resolve_failed", message: error.localizedDescription, details: nil))
    }
  }

  // MARK: iCloud

  /// Accepts either the real file path or its ".Name.mp3.icloud" placeholder.
  private func requestDownload(_ path: String) {
    var url = URL(fileURLWithPath: path)
    let name = url.lastPathComponent
    if name.hasPrefix("."), name.hasSuffix(".icloud") {
      let real = String(name.dropFirst().dropLast(".icloud".count))
      url = url.deletingLastPathComponent().appendingPathComponent(real)
    }
    try? FileManager.default.startDownloadingUbiquitousItem(at: url)
  }

  private static func topViewController() -> UIViewController? {
    let scenes = UIApplication.shared.connectedScenes.compactMap { $0 as? UIWindowScene }
    let windows = scenes.flatMap { $0.windows }
    var top = (windows.first { $0.isKeyWindow } ?? windows.first)?.rootViewController
    while let presented = top?.presentedViewController { top = presented }
    return top
  }
}
