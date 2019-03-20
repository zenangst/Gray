import Cocoa

enum ImportError: Error {
  case missingUrl
}

class ImportController: NSObject {
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
    for line in contents.split(separator: "\n") {
      Swift.print("\(line)")
    }
  }
}
