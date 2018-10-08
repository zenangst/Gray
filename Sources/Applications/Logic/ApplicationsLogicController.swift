import Foundation
import Cocoa

class ApplicationsLogicController {
  enum PlistKey: String {
    case bundleName = "CFBundleName"
    case bundleIdentifier = "CFBundleIdentifier"
    case requiresAquaSystemAppearance = "NSRequiresAquaSystemAppearance"
  }

  func load(then handler: (MainViewController.State) -> Void) {
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
      handler(.viewApplications(applications))
    } catch {}
  }

  func toggleAppearance(for application: Application,
                        newAppearance appearance: Application.Appearance,
                        then handler: @escaping (MainViewController.State) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async { [weak self] in
      let shell = Shell()
      let newSetting: String
      switch appearance {
      case .light, .system:
        newSetting = "true"
      case .dark:
        newSetting = "false"
      }

      let runningApplication = NSRunningApplication.runningApplications(withBundleIdentifier: application.bundleIdentifier).first

      if !application.url.path.contains("CoreServices") {
        runningApplication?.terminate()
      }

      let command: String
      if application.appearance == .system {
        command = """
        /usr/bin/killall -u $USER cfprefsd
        /usr/libexec/PlistBuddy -c \"Add :NSRequiresAquaSystemAppearance \(newSetting)\" \(application.preferencesUrl.path)
        defaults write \(application.bundleIdentifier) NSRequiresAquaSystemAppearance -bool \(newSetting)
        defaults read \(application.bundleIdentifier) NSRequiresAquaSystemAppearance \(application.preferencesUrl.path)
        """
      } else {
        // The cfprefsd is killed for the current user to avoid plist caching.
        // PlistBuddy is used to set new values.
        // Defaults is invoked in order to renew the cache.
        // https://nethack.ch/2014/03/30/quick-tip-flush-os-x-mavericks-plist-file-cache/
        command = """
        /usr/bin/killall -u $USER cfprefsd
        /usr/libexec/PlistBuddy -c \"Set :NSRequiresAquaSystemAppearance \(newSetting)\" \(application.preferencesUrl.path)
        defaults read \(application.bundleIdentifier) NSRequiresAquaSystemAppearance \(application.preferencesUrl.path)
        """
      }

      NSLog("New settings for \(application.name) = \(newSetting)")
      NSLog("command: \(command)")

      let output = shell.execute(command: command)
      NSLog("output: (\(output))")


      if runningApplication != nil && !application.url.path.contains("CoreServices") {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
          NSWorkspace.shared.launchApplication(withBundleIdentifier: application.bundleIdentifier,
                                               options: [.withoutActivation, .async],
                                               additionalEventParamDescriptor: nil,
                                               launchIdentifier: nil)
        })
      } else {
        let shell = Shell()
        shell.execute(command: "killall", arguments: ["-9", "\(application.name)"])
      }
      DispatchQueue.main.async {
        self?.load(then: handler)
      }
    }
  }

  private func processApplications(_ appUrls: [URL], at directoryUrl: URL) throws -> [Application] {
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
        let bundleName = plist.value(forPlistKey: .bundleName) else { continue }

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
