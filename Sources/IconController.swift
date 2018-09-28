import Cocoa

class IconController {
  let cache = NSCache<NSString, NSImage>()

  func icon(for application: Application) -> NSImage {
    if let image = cache.object(forKey: application.url.path as NSString) {
      return image
    }

    let image = NSWorkspace.shared.icon(forFile: application.url.path)
    cache.setObject(image, forKey: application.url.path as NSString)
    return image
  }
}
