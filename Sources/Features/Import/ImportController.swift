import Cocoa

enum ImportError: Error {
  case missingUrl
}

protocol ImportControllerDelegate: class {
  func importController(_ controller: ImportController,
                        didStartImport: Bool,
                        settingsCount: Int)
  func importController(_ controller: ImportController,
                        offset: Int,
                        importProgress progress: Double,
                        settingsCount: Int)
  func importController(_ controller: ImportController,
                        didFinishImport: Bool,
                        settingsCount: Int)
}

class ImportController: NSObject {
  weak var delegate: ImportControllerDelegate?
  lazy var logicController = ApplicationsLogicController()
  var openPanel: NSOpenPanel?

  func openDialog() {
    let panel = NSOpenPanel()
    panel.canChooseDirectories = false
    panel.allowedFileTypes = ["txt"]
    panel.allowsMultipleSelection = false
    panel.begin(completionHandler: { try? self.handleDialogResponse($0) })
    openPanel = panel
  }

  func handleDialogResponse(_ response: NSApplication.ModalResponse) throws {
    guard response == NSApplication.ModalResponse.OK,
      let destination = openPanel?.urls.first else {
      throw ImportError.missingUrl
    }
    defer { openPanel = nil }
    do {
      try self.validateAndImport(at: destination, handler: String.init)
    } catch let error {
      debugPrint(error)
    }
  }

  func validateAndImport(at url: URL, handler: (URL) throws -> String) rethrows {
    let contents = try handler(url)

    DispatchQueue.global(qos: .utility).async { [weak self] in
      guard let strongSelf = self else { return }

      let commands = contents.split(separator: "\n").compactMap(String.init)
      let shell = Shell()

      let validCommands = commands.filter(strongSelf.validateCommand)

      DispatchQueue.main.async {
        strongSelf.delegate?.importController(strongSelf,
                                              didStartImport: true,
                                              settingsCount: validCommands.count)
      }

      let total = Double(validCommands.count)

      for (offset, command) in validCommands.enumerated() {
        let output = shell.execute(command: command)
        if output.isEmpty {
          let progress = Double(offset + 1) / Double(total) * Double(100)
          DispatchQueue.main.async {
            strongSelf.delegate?.importController(strongSelf,
                                                  offset: offset + 1,
                                                  importProgress: progress,
                                                  settingsCount: validCommands.count)
          }
          Swift.print("✅ \(command)")
        } else {
          Swift.print("❌ \(command)")
        }
      }

      DispatchQueue.main.async {
        strongSelf.delegate?.importController(strongSelf,
                                              didFinishImport: true,
                                              settingsCount: validCommands.count)
      }
    }
  }

  private func validateCommand(_ string: String) -> Bool {
    let words = string.split(separator: " ").compactMap(String.init)

    guard words.count == 6 else { return false }
    guard words[0] == "defaults" else { return false }
    guard words[1] == "write" else { return false }
    guard words[3] == "NSRequiresAquaSystemAppearance" else { return false }
    guard words[4] == "-bool" else { return false }
    guard ["true", "false"].contains(words[5])  else { return false }

    return true
  }
}
