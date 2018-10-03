import Foundation

class Shell {
  let queue = DispatchQueue(label: "shell-execution")

  @discardableResult func execute(command: String,
                                  arguments: [String] = [],
                                  at path: String = ".") throws -> String {
    let process = Process()
    let path = path.replacingOccurrences(of: " ", with: "\\ ")
    let arguments = arguments.joined(separator: " ")
    let command = "cd \(path) && \(command) \(arguments)"
    return try launch(process, command: command)
  }

  private func launch(_ process: Process,
                      command: String,
                      withShell: String = "/bin/bash") throws -> String {
    let pipe = Pipe()
    var output = Data()

    pipe.fileHandleForReading.readabilityHandler = { handler in
      if handler.availableData.count > 0 {
        output.append(handler.availableData)
        handler.waitForDataInBackgroundAndNotify()
      }
    }

    process.launchPath = withShell
    process.arguments = ["-c", command]
    process.standardOutput = pipe
    process.launch()
    process.waitUntilExit()

    return queue.sync {
      if let output = String(data: output, encoding: .utf8), output.hasSuffix("\n") {
        let endIndex = output.index(before: output.endIndex)
        return String(output[..<endIndex])
      }

      return ""
    }
  }
}
