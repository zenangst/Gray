import Cocoa

class AlertsController: VersionControllerDelegate {
  let versionController: VersionController

  init(versionController: VersionController) {
    self.versionController = versionController
  }

  func showNewVersionDialog(version: String, handler completion : (Bool)->Void) {
    let alert = NSAlert()
    alert.messageText = "A new version is available."
    alert.informativeText = "Version \(version) is available for download on GitHub."
    alert.alertStyle = .informational
    alert.addButton(withTitle: "Open GitHub")
    alert.addButton(withTitle: "OK")
    completion(alert.runModal() == .alertFirstButtonReturn)
  }

  func showNoNewUpdates() {
    let alert = NSAlert()
    alert.messageText = "You’re up-to-date!"
    alert.informativeText = "Gray \(versionController.currentVersion()) is currently the newest version available."
    alert.alertStyle = .informational
    alert.addButton(withTitle: "OK")
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
