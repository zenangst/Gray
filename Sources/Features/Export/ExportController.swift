import Cocoa

class ExportController: NSObject,
  NSOpenSavePanelDelegate,
ApplicationsLogicControllerDelegate {
  lazy var logicController = ApplicationsLogicController()
  lazy var panel = NSSavePanel()
  var destination: URL?
  var filename: String?

  // MARK: - Public methods

  func openDialog() {
    logicController.delegate = self
    let panel = NSSavePanel()
    panel.nameFieldStringValue = "gray-settings.txt"
    panel.delegate = self
    destination = panel.url

    panel.begin { response in
      if response == NSApplication.ModalResponse.OK {
        self.logicController.load()
      }
    }
  }

  // MARK: - NSOpenSavePanelDelegate

  func panel(_ sender: Any, userEnteredFilename filename: String, confirmed okFlag: Bool) -> String? {
    self.filename = filename
    return filename
  }

  func panel(_ sender: Any, didChangeToDirectoryURL url: URL?) {
    self.destination = url
  }

  // MARK: - ApplicationsLogicController

  func applicationsLogicController(_ controller: ApplicationsLogicController,
                                   didLoadApplication application: Application,
                                   offset: Int,
                                   total: Int) {}

  func applicationsLogicController(_ controller: ApplicationsLogicController,
                                   didLoadApplications applications: [Application]) {
    guard let destination = destination,
      let filename = filename else { return }

    var path = destination.absoluteString.replacingOccurrences(of: filename, with: "")
    path += filename

    guard let saveDestination = URL(string: path) else { return }

    var output = ""
    for application in applications where application.appearance != .system {

      let booleanString = application.appearance == .light
        ? "true"
        : "false"

      let command = """
      defaults write \(application.bundleIdentifier) NSRequiresAquaSystemAppearance -bool \(booleanString)\n
      """
      output += command
    }

    Swift.print("Write file to: \(saveDestination)")

    do  {
      try (output as NSString).write(to: saveDestination,
                                     atomically: true,
                                     encoding: String.Encoding.utf8.rawValue)
    } catch let error {
      debugPrint(error)
    }
  }
}
