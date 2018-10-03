import Foundation
import Cocoa

class ApplicationsLogicController {
  enum PlistKey: String {
    case bundleName = "CFBundleName"
    case bundleIdentifier = "CFBundleIdentifier"
    case requiresAquaSystemAppearance = "NSRequiresAquaSystemAppearance"
  }

  func load(then handler: (ApplicationsViewController.State) -> Void) {
    do {
      let applicationDirectory = try FileManager.default.url(for: .allApplicationsDirectory,
                                                             in: .localDomainMask,
                                                             appropriateFor: nil,
                                                             create: false)
      var urls = try FileManager.default.contentsOfDirectory(at: applicationDirectory,
                                                              includingPropertiesForKeys: nil,
                                                              options: .skipsHiddenFiles)
      urls.append(URL(string: "file:///System/Library/CoreServices/Finder.app")!)
      let applications = try processApplications(urls, at: applicationDirectory)
      handler(.list(applications))
    } catch {}
  }

  func toggleAppearance(for application: Application,
                        newAppearance appearance: Application.Appearance,
                        then handler: @escaping (ApplicationsViewController.State) -> Void) {
    DispatchQueue.global(qos: .utility).async {
      let newSetting = appearance == .light ? "YES" : "NO"
      do {
        let shell = Shell()
        let applicationIsRunning = !NSRunningApplication.runningApplications(withBundleIdentifier: application.bundleIdentifier).isEmpty
        if applicationIsRunning && !application.url.path.contains("CoreServices") {
          do {
            let script = """
            tell application "\(application.name)" to quit
            """
            NSAppleScript(source: script)?.executeAndReturnError(nil)
          }
        }

        try shell.execute(command: "/usr/bin/killall", arguments: ["-u", "$USER", "cfprefsd"])
        try shell.execute(command: "defaults write \(application.bundleIdentifier) NSRequiresAquaSystemAppearance -bool \(newSetting)")

        if applicationIsRunning && !application.url.path.contains("CoreServices") {
          NSWorkspace.shared.launchApplication(application.name)
        } else {
          try shell.execute(command: "killall", arguments: ["-9", "\(application.name)"])
        }

        DispatchQueue.main.async { [weak self] in
          self?.load(then: handler)
        }
      } catch {}
    }
  }

  private func processApplications(_ appUrls: [URL], at directoryUrl: URL) throws -> [Application] {
    var applications = [Application]()

    let libraryDirectory = try FileManager.default.url(for: .libraryDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)

    for url in appUrls {
      let path = url.path
      let infoPath = "\(path)/Contents/Info.plist"
      guard FileManager.default.fileExists(atPath: infoPath),
        let plist = NSDictionary.init(contentsOfFile: infoPath),
        let bundleIdentifier = plist.value(forPlistKey: .bundleIdentifier),
        let bundleName = plist.value(forPlistKey: .bundleName) else { continue }

      let suffix = "Preferences/\(bundleIdentifier).plist"
      let appPreferenceUrl = libraryDirectory.appendingPathComponent(suffix)
      let appContainerPreferenceUrl = libraryDirectory.appendingPathComponent("Containers/\(bundleIdentifier)/Data/Library/\(suffix)")
      var resolvedAppPreferenceUrl = appPreferenceUrl
      var applicationPlist: NSDictionary? = nil

      if let plist = NSDictionary.init(contentsOfFile: appContainerPreferenceUrl.path) {
        applicationPlist = plist
        resolvedAppPreferenceUrl = appContainerPreferenceUrl
      } else if let plist = NSDictionary.init(contentsOfFile: appPreferenceUrl.path) {
        applicationPlist = plist
      }

      guard let resolvedPlist = applicationPlist else { continue }

      let app = Application(bundleIdentifier: bundleIdentifier,
                            name: bundleName,
                            url: url,
                            preferencesUrl: resolvedAppPreferenceUrl,
                            appearance: resolvedPlist.appearance())
      applications.append(app)
    }
    return applications.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
  }
}

fileprivate extension NSDictionary {
  func appearance() -> Application.Appearance {
    let key = ApplicationsLogicController.PlistKey.requiresAquaSystemAppearance.rawValue
    let result = (value(forKey: key) as? Bool) ?? false
    return result ? .light : .dark
  }

  func value(forPlistKey plistKey: ApplicationsLogicController.PlistKey) -> String? {
    return value(forKey: plistKey.rawValue) as? String
  }
}
