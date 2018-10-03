import Foundation

class Shell {
  @discardableResult func execute(command: String,
                                  arguments: [String] = [],
                                  at path: String = ".") -> String {
    let process = Process()
    let path = path.replacingOccurrences(of: " ", with: "\\ ")
    let arguments = arguments.joined(separator: " ")
    let command = "cd \(path) && \(command) \(arguments) &"
    return process.shell(command: command)
  }
}


extension Process {
  public func shell(command: String) -> String {
    let pipe = Pipe()

    launchPath = "/bin/bash"
    arguments = ["-c", command]
    standardOutput = pipe

    launch()
    waitUntilExit()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: String.Encoding.utf8) ?? ""
  }
}
