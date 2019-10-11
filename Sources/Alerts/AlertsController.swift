import Cocoa

class AlertsController: VersionControllerDelegate {
  let versionController: VersionController

  init(versionController: VersionController) {
    self.versionController = versionController
  }

  func showNewVersionDialog(version: String, handler completion : (Bool)->Void) {
    let alert = NSAlert()
    alert.messageText = "A new version is available.".localized
    alert.informativeText = "Version".localized + " \(version) " + "is available for download on GitHub.".localized
    alert.alertStyle = .informational
    alert.addButton(withTitle: "Open GitHub".localized)
    alert.addButton(withTitle: "OK".localized)
    completion(alert.runModal() == .alertFirstButtonReturn)
  }

  func showNoNewUpdates() {
    let alert = NSAlert()
    alert.messageText = "You’re up-to-date!".localized
    alert.informativeText = "Gray \(versionController.currentVersion()) " + "is currently the newest version available.".localized
    alert.alertStyle = .informational
    alert.addButton(withTitle: "OK".localized)
    alert.runModal()
  }

  // MARK: - VersionControllerDelegate

  func versionController(_ controller: VersionController, foundNewVersion version: String) {
    showNewVersionDialog(version: version) { openGitHub in
      if openGitHub {
        let url = URL(string: "https://github.com/zenangst/Gray/releases/tag/\(version)")!
        NSWorkspace.shared.open(url)
      }
    }
  }
}
