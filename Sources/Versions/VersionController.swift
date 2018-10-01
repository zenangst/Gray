import Foundation

protocol VersionControllerDelegate: class {
  func versionController(_ controller: VersionController, foundNewVersion version: String)
}

class VersionController {
  weak var delegate: VersionControllerDelegate?
  let urlSession = URLSession.shared

  func currentVersion() -> String {
    return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
  }

  func checkForNewVersion(then handler: @escaping (Bool) -> Void) {
    let url = URL(string: "https://raw.githubusercontent.com/zenangst/Gray/master/.current-version")!
    let task = URLSession.shared.dataTask(with: url) {
      [weak self] (data, response, error) in
      guard let strongSelf = self,
        let data = data,
        let body = String.init(data: data, encoding: .utf8) else {
          DispatchQueue.main.async { handler(false) }
          return
      }

      let newVersion = body.replacingOccurrences(of: "\n", with: "")

      if strongSelf.currentVersion() != newVersion,
        newVersion.compare(strongSelf.currentVersion(), options: .numeric) == .orderedDescending {
        DispatchQueue.main.async {
          strongSelf.delegate?.versionController(strongSelf, foundNewVersion: newVersion)
        }
      } else {
        DispatchQueue.main.async { handler(false) }
      }
    }
    task.resume()
  }
}
