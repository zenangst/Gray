import Cocoa

class SystemLogicController {
  func readSystemPreferences() -> [SystemPreference] {
    let systemPreferences = [
      SystemPreference(icon: NSImage(named: .init("System Appearance"))!,
                       name: "System",
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
    ]

    return systemPreferences
  }

  func load(then handler: (SystemPreferenceViewController.State) -> Void) {
    handler(.view(readSystemPreferences()))
  }

  func toggleSystemPreference(_ systemPreference: SystemPreference,
                              then handler: @escaping (SystemPreferenceViewController.State) -> Void) {
    switch systemPreference.type {
    case .appleScript:
      var error: NSDictionary?
      NSAppleScript(source: systemPreference.script)?.executeAndReturnError(&error)
      if error != nil {
        requestPermission { (_) in }
      } else {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
          handler(.view(self.readSystemPreferences()))
        }
      }
    case .shellScript:
      break
    }
  }

  private func showSystemPreferencesDialog(handler completion : (Bool)->Void) {
    let alert = NSAlert()
    alert.messageText = "Enable Accessibility."
    alert.informativeText = "For this Gray to work properly, you will have to enable accessibility. You can do this by adding it under the Privacy-tab under Security & Privacy in System Preferences."
    alert.alertStyle = .informational
    alert.addButton(withTitle: "System Preferences")
    alert.addButton(withTitle: "OK")
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
