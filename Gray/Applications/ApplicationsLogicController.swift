import Foundation

class ApplicationsLogicController {
  enum Path: String {
    case applicationDirectory = "/Applications"
  }

  enum PlistKey: String {
    case bundleIdentifier = "CFBundleIdentifier"
  }

  func load(then handler: (ApplicationsViewController.State) -> Void) {
    do {
      let path = Path.applicationDirectory.rawValue
      let files = try FileManager.default.contentsOfDirectory(atPath: path)
      let apps = files.filter({ $0.contains(".app") })
        .sorted(by: { $0.lowercased() < $1.lowercased() } )
      handler(.list(processApplications(apps, atPath: path)))
    } catch {}
  }

  private func processApplications(_ apps: [String], atPath path: String) -> [Application] {
    var applications = [Application]()
    for app in apps {
      let appPath = "\(path)/\(app)"
      let infoPath = "\(appPath)/Contents/Info.plist"
      guard FileManager.default.fileExists(atPath: infoPath),
        let plist = NSDictionary.init(contentsOfFile: infoPath),
        let bundleIdentifier = plist.value(forKey: PlistKey.bundleIdentifier.rawValue) as? String else { return [] }

      let app = Application(bundleIdentifier: bundleIdentifier,
                            name: app.replacingOccurrences(of: ".app", with: ""),
                            path: appPath)
      applications.append(app)
    }
    return applications
  }
}
