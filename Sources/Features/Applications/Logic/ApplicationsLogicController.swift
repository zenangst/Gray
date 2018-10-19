import Foundation
import Cocoa

class ApplicationsLogicController {
  let queue = DispatchQueue(label: "ApplicationQueue")

  enum PlistKey: String {
    case bundleName = "CFBundleName"
    case bundleIdentifier = "CFBundleIdentifier"
    case requiresAquaSystemAppearance = "NSRequiresAquaSystemAppearance"
  }

  func load(then handler: (ApplicationsViewController.State) -> Void) {
    do {
      let excludedBundles = ["com.vmware.fusion"]

      var applicationUrls = [URL]()
      applicationUrls.append(URL(string: "file:///System/Library/CoreServices/Finder.app")!)
      for url in try applicationLocations() {
        guard FileManager.default.fileExists(atPath: url.path) else { continue }

        let urls = try FileManager.default.contentsOfDirectory(at: url,
                                                               includingPropertiesForKeys: nil,
                                                               options: .skipsHiddenFiles)
        applicationUrls.append(contentsOf: urls)
      }

      let applications = try parseApplicationUrls(applicationUrls, excludedBundles: excludedBundles)
      handler(.view(applications))
    } catch {}
  }

  func toggleAppearance(_ newAppearance: Application.Appearance,
                        for application: Application,
                        then handler: @escaping (ApplicationsViewController.State) -> Void) {
    queue.async { [weak self] in
      let shell = Shell()

      // The cfprefsd is killed for the current user to avoid plist caching.
      // PlistBuddy is used to set new values.
      // Defaults is invoked in order to renew the cache.
      // https://nethack.ch/2014/03/30/quick-tip-flush-os-x-mavericks-plist-file-cache/
      let command: String
      switch newAppearance {
      case .light:
        command = """
        /usr/bin/killall -u $USER cfprefsd
        defaults write \(application.bundleIdentifier) NSRequiresAquaSystemAppearance -bool true
        defaults read \(application.bundleIdentifier) NSRequiresAquaSystemAppearance \(application.preferencesUrl.path)
        """
      case .dark:
        command = """
        /usr/bin/killall -u $USER cfprefsd
        defaults write \(application.bundleIdentifier) NSRequiresAquaSystemAppearance -bool false
        defaults read \(application.bundleIdentifier) NSRequiresAquaSystemAppearance \(application.preferencesUrl.path)
        """
      case .system:
        command = """
        /usr/bin/killall -u $USER cfprefsd
        defaults delete \(application.bundleIdentifier) NSRequiresAquaSystemAppearance
        defaults read \(application.bundleIdentifier) NSRequiresAquaSystemAppearance \(application.preferencesUrl.path)
        """
      }

      let runningApplication = NSRunningApplication.runningApplications(withBundleIdentifier: application.bundleIdentifier).first

      if !application.url.path.contains("CoreServices") {
        runningApplication?.terminate()
      }

      NSLog("Gray: New settings for \(application.name) = \(newAppearance)")
      NSLog("Gray: Command: \(command)")
      let output = shell.execute(command: command)
      NSLog("Gray: terminal output: (\(output))")

      if runningApplication != nil && !application.url.path.contains("CoreServices") {
        NSWorkspace.shared.launchApplication(withBundleIdentifier: application.bundleIdentifier,
                                             options: [.withoutActivation],
                                             additionalEventParamDescriptor: nil,
                                             launchIdentifier: nil)
      } else {
        let shell = Shell()
        shell.execute(command: "killall", arguments: ["-9", "\(application.name)"])
      }
      DispatchQueue.main.async {
        self?.load(then: handler)
      }
    }
  }

  private func applicationLocations() throws -> [URL] {
    var directories = [URL]()
    let applicationDirectory = try FileManager.default.url(for: .allApplicationsDirectory,
                                                           in: .localDomainMask,
                                                           appropriateFor: nil,
                                                           create: false)
    directories.append(applicationDirectory)
    directories.append(applicationDirectory.appendingPathComponent("Utilities"))
    directories.append(applicationDirectory.appendingPathComponent("Xcode.app/Contents/Applications"))

    return directories
  }

  private func parseApplicationUrls(_ appUrls: [URL], excludedBundles: [String] = []) throws -> [Application] {
    var applications = [Application]()
    let shell = Shell()
    let sip = shell.execute(command: "csrutil status").contains("enabled")
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
        let bundleName = plist.value(forPlistKey: .bundleName),
        !excludedBundles.contains(bundleIdentifier) else { continue }

      // Exclude Electron apps
      let electronPath = "\(url.path)/Contents/Frameworks/Electron Framework.framework"
      if FileManager.default.fileExists(atPath: electronPath) {
        continue
      }

      let suffix = "Preferences/\(bundleIdentifier).plist"
      let appPreferenceUrl = libraryDirectory.appendingPathComponent(suffix)
      let appContainerPreferenceUrl = libraryDirectory.appendingPathComponent("Containers/\(bundleIdentifier)/Data/Library/\(suffix)")
      var resolvedAppPreferenceUrl = appPreferenceUrl
      var applicationPlist: NSDictionary? = nil

      if FileManager.default.fileExists(atPath: appContainerPreferenceUrl.path),
        let plist = NSDictionary.init(contentsOfFile: appContainerPreferenceUrl.path) {
        applicationPlist = plist
        resolvedAppPreferenceUrl = appContainerPreferenceUrl
      } else if let plist = NSDictionary.init(contentsOfFile: appPreferenceUrl.path) {
        applicationPlist = plist
      }

      // Check if Gray has enough priviliges to change appearance for application
      let restricted = sip &&
        FileManager.default.fileExists(atPath: appContainerPreferenceUrl.path) &&
        NSDictionary.init(contentsOfFile: appContainerPreferenceUrl.path) == nil

      let app = Application(bundleIdentifier: bundleIdentifier,
                            name: bundleName,
                            url: url,
                            preferencesUrl: resolvedAppPreferenceUrl,
                            appearance: applicationPlist?.appearance() ?? .system,
                            restricted: restricted)
      applications.append(app)
    }
    return applications.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
  }
}

fileprivate extension NSDictionary {
  func appearance() -> Application.Appearance {
    let key = ApplicationsLogicController.PlistKey.requiresAquaSystemAppearance.rawValue
    if let result = (value(forKey: key) as? Bool) {
      return result ? .light : .dark
    } else {
      return .system
    }
  }

  func value(forPlistKey plistKey: ApplicationsLogicController.PlistKey) -> String? {
    return value(forKey: plistKey.rawValue) as? String
  }
}
