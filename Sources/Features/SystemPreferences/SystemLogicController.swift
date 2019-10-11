import Cocoa

protocol SystemLogicControllerDelegate: class {
  func systemLogicController(_ controller: SystemLogicController,
                             didLoadPreferences preferences: [SystemPreferenceViewModel])
}

class SystemLogicController {
  weak var delegate: SystemLogicControllerDelegate?

  func readSystemPreferences() -> [SystemPreferenceViewModel] {
    let icon = NSImage(named: .init("System Appearance"))!
    let preference = SystemPreference(icon: icon,
                                      name: "System".localized,
                                      bundleIdentifier: "com.apple.dock",
                                      value: true,
                                      type: .appleScript,
                                      script: """
        tell application "System Events"
          tell appearance preferences
            set dark mode to not dark mode
          end tell
        end tell
        """)

    let subtitle = NSApplication.shared.mainWindow?.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        ? "Dark appearance".localized : "Light appearance".localized

    let systemPreferences = [
      SystemPreferenceViewModel(icon: icon,
                                title: preference.name,
                                subtitle: subtitle,
                                preference: preference)
    ]

    return systemPreferences
  }

  func load() {
    delegate?.systemLogicController(self, didLoadPreferences: readSystemPreferences())
  }

  func toggleSystemPreference(_ systemPreference: SystemPreference) {
    switch systemPreference.type {
    case .appleScript:
      var error: NSDictionary?
      NSAppleScript(source: systemPreference.script)?.executeAndReturnError(&error)
      if error != nil {
        requestPermission { (_) in }
      } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
          guard let strongSelf = self else { return }
          strongSelf.delegate?.systemLogicController(strongSelf, didLoadPreferences: strongSelf.readSystemPreferences())
        }
      }
    case .shellScript:
      break
    }
  }

  private func showSystemPreferencesDialog(handler completion : (Bool)->Void) {
    let alert = NSAlert()
    alert.messageText = "Enable Accessibility.".localized
    alert.informativeText = "For this Gray to work properly, you will have to enable accessibility. You can do this by adding it under the Privacy-tab under Security & Privacy in System Preferences.".localized
    alert.alertStyle = .informational
    alert.addButton(withTitle: "System Preferences".localized)
    alert.addButton(withTitle: "OK".localized)
    completion(alert.runModal() == .alertFirstButtonReturn)
  }

  func requestPermission(retryOnInternalError: Bool = true,
                         then process: @escaping (_ authorized: Bool) -> Void
    ) {
    DispatchQueue.global().async {
      let systemEvents = "com.apple.systemevents"
      NSWorkspace.shared.launchApplication(
        withBundleIdentifier: systemEvents,
        additionalEventParamDescriptor: nil,
        launchIdentifier: nil
      )
      let target = NSAppleEventDescriptor(bundleIdentifier: systemEvents)
      let status = AEDeterminePermissionToAutomateTarget(target.aeDesc, typeWildCard, typeWildCard, true)
      switch Int(status) {
      case Int(noErr):
        return process(true)
      case errAEEventNotPermitted:
        break
      case errOSAInvalidID, -1751,
           errAEEventWouldRequireUserConsent,
           procNotFound:
        if retryOnInternalError {
          self.requestPermission(retryOnInternalError: false, then: process)
        }
      default:
        break
      }
      process(false)
    }
  }
}
