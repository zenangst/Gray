import Foundation
import Cocoa

class ApplicationsLogicController {
  let queue = DispatchQueue(label: "ApplicationQueue", qos: .userInitiated)

  enum PlistKey: String {
    case bundleName = "CFBundleName"
    case iconFile = "CFBundleIconFile"
    case bundleIdentifier = "CFBundleIdentifier"
    case applicationIsAgent = "LSUIElement"
    case requiresAquaSystemAppearance = "NSRequiresAquaSystemAppearance"
  }

  func load(then handler: @escaping (ApplicationsViewController.State) -> Void) {
    queue.async { [weak self] in
      guard let strongSelf = self else { return }
      do {
        let excludedBundles = ["com.vmware.fusion"]
        var applicationUrls = [URL]()
        for path in try strongSelf.applicationLocations() {
          applicationUrls.append(contentsOf: strongSelf.recursiveParse(at: path))
        }
        let applications = try strongSelf.parseApplicationUrls(applicationUrls,
                                                               excludedBundles: excludedBundles)
        DispatchQueue.main.async {
          handler(.view(applications))
        }
      } catch {}
    }
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
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
          NSWorkspace.shared.launchApplication(withBundleIdentifier: application.bundleIdentifier,
                                               options: [.withoutActivation],
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

  private func applicationLocations() throws -> [URL] {
    var directories = [URL]()
    let applicationDirectory = try FileManager.default.url(for: .allApplicationsDirectory,
                                                           in: .localDomainMask,
                                                           appropriateFor: nil,
                                                           create: false)
    let applicationDirectoryU = try FileManager.default.url(for: .applicationDirectory,
                                                           in: .userDomainMask,
                                                           appropriateFor: nil,
                                                           create: false)
    let homeDirectory = FileManager.default.homeDirectoryForCurrentUser
    let applicationDirectoryD = URL(fileURLWithPath: "/Developer/Applications")
    let applicationDirectoryN = URL(fileURLWithPath: "/Network/Applications")
    let applicationDirectoryND = URL(fileURLWithPath: "/Network/Developer/Applications")
    let coreServicesDirectory = URL(fileURLWithPath: "/System/Library/CoreServices")
    let applicationDirectoryS = URL(fileURLWithPath: "/Users/Shared/Applications")
    
    // macOS default Applications directories
    directories.append(applicationDirectory) // including macOS default paths ./Utilities & ./Demos
    directories.append(applicationDirectoryU) // including macOS default paths ./Utilities & ./Demos
    directories.append(homeDirectory.appendingPathComponent("Developer/Applications"))
    directories.append(applicationDirectoryD)
    directories.append(applicationDirectoryN) // including macOS default paths ./Utilities & ./Demos
    directories.append(applicationDirectoryND)    
    
    // other non-default application directories
    directories.append(coreServicesDirectory) // Gray *hopefully* excludes any non-application bundles; this path will also include Finder, Stocks etc. and several miscellaneous system applications in subdirectory /System/Library/CoreServices/Applications
    directories.append(applicationDirectory.appendingPathComponent("Xcode.app/Contents/Applications"))
    directories.append(applicationDirectory.appendingPathComponent("Xcode.app/Contents/Developer/Applications"))
    directories.append(homeDirectory.appendingPathComponent("Library/Developer/Xcode/DerivedData")) // default location for subdirectories containing applications freshly built with Xcode                 
    directories.append(applicationDirectoryS)

    return directories
  }

  private func recursiveParse(at url: URL) -> [URL] {
    var result = [URL]()
    guard FileManager.default.fileExists(atPath: url.path),
      let contents = try? FileManager.default.contentsOfDirectory(at: url,
                                                                  includingPropertiesForKeys: nil,
                                                                  options: .skipsHiddenFiles) else { return [] }
    for file in contents {
      var isDirectory: ObjCBool = true
      let isFolder = FileManager.default.fileExists(atPath: file.path, isDirectory: &isDirectory)
      if isFolder && file.pathExtension != "app" && url.path.contains("/Applications") {
        result.append(contentsOf: recursiveParse(at: file))
      } else {
        result.append(file)
      }
    }

    return result
  }

  private func parseApplicationUrls(_ appUrls: [URL],
                                    excludedBundles: [String] = []) throws -> [Application] {
    var applications = [Application]()
    let shell = Shell()
    let sip = shell.execute(command: "csrutil status").contains("enabled")
    let libraryDirectory = try FileManager.default.url(for: .libraryDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: false)
    var addedApplicationNames = [String]()
    for url in appUrls {
      let path = url.path
      let infoPath = "\(path)/Contents/Info.plist"
      guard FileManager.default.fileExists(atPath: infoPath),
        let plist = NSDictionary.init(contentsOfFile: infoPath),
        let bundleIdentifier = plist.value(forPlistKey: .bundleIdentifier),
        let bundleName = plist.value(forPlistKey: .bundleName),
        !addedApplicationNames.contains(bundleName),
        !excludedBundles.contains(bundleIdentifier) else { continue }

      if shouldExcludeApplication(with: plist, applicationUrl: url) == true { continue }

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
                            name: bundleName, url: url,
                            preferencesUrl: resolvedAppPreferenceUrl,
                            appearance: applicationPlist?.appearance() ?? .system,
                            restricted: restricted)
      applications.append(app)
      addedApplicationNames.append(bundleName)
    }
    return applications.sorted(by: { $0.name.lowercased() < $1.name.lowercased() })
  }

  private func shouldExcludeApplication(with plist: NSDictionary, applicationUrl url: URL) -> Bool {
    var shouldExcludeOnKeyword: Bool = false
    // Exclude applications with certain keywords in their name.
    let excludeKeywords = [
      "handler", "agent", "migration",
      "problem", "setup", "uiserver",
      "install", "system image", "escrow"]

    for keyword in excludeKeywords {
      if url.lastPathComponent.lowercased().contains(keyword) {
        shouldExcludeOnKeyword = true
        break
      }
    }

    if shouldExcludeOnKeyword {
      return true
    }

    // Exclude applications that don't have an icon file.
    if plist.value(forPlistKey: .iconFile) == nil && url.path.contains("CoreServices")  {
      return true
    }

    // Exclude Electron apps
    let electronPath = "\(url.path)/Contents/Frameworks/Electron Framework.framework"
    if FileManager.default.fileExists(atPath: electronPath) {
      return true
    }

    return false
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
