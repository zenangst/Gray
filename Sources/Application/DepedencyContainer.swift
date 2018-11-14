import Cocoa

class DependencyContainer: IconStore {
  private let iconController = IconController()

  func loadIcon(for application: Application, then handler: @escaping (NSImage?) -> Void) {
    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
      guard let strongSelf = self else { return }
      let image = strongSelf.iconController.icon(for: application)
      DispatchQueue.main.async { handler(image) }
    }
  }
}

protocol IconStore {
  func loadIcon(for application: Application, then handler: @escaping (NSImage?) -> Void)
}
