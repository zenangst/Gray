import Cocoa

class IconController {
  let cache = NSCache<NSString, NSImage>()

  func icon(for application: Application) -> NSImage? {
    if let image = cache.object(forKey: application.url.path as NSString) {
      return image
    }

    var image: NSImage
    if let cachedImage = loadImageFromDisk(for: application) {
      image = cachedImage
      return image
    } else {
      image = NSWorkspace.shared.icon(forFile: application.url.path)
      var imageRect: CGRect = .init(origin: .zero, size: CGSize(width: 32, height: 32))
      let imageRef = image.cgImage(forProposedRect: &imageRect, context: nil, hints: nil)
      if let imageRef = imageRef {
        image = NSImage(cgImage: imageRef, size: imageRect.size)
      }
    }

    saveImageToDisk(image, application: application)
    cache.setObject(image, forKey: application.url.path as NSString)
    return image
  }

  func loadImageFromDisk(for application: Application) -> NSImage? {
    if let applicationFile = try? applicationCacheDirectory()
      .appendingPathComponent("\(application.bundleIdentifier).tiff") {
      if FileManager.default.fileExists(atPath: applicationFile.path) {
        let image = NSImage.init(contentsOf: applicationFile)
        return image
      }
    }

    return nil
  }

  func saveImageToDisk(_ image: NSImage, application: Application) {
    do {
      let applicationFile = try applicationCacheDirectory()
        .appendingPathComponent("\(application.bundleIdentifier).tiff")

      if let tiff = image.tiffRepresentation {
        if let imgRep = NSBitmapImageRep(data: tiff) {
          if let data = imgRep.representation(using: .tiff, properties: [:]) {
            try data.write(to: applicationFile)
          }
        }
      }

    } catch let error {
      Swift.print(error)
    }
  }

  func applicationCacheDirectory() throws -> URL {
    let url = try FileManager.default.url(for: .cachesDirectory,
                                          in: .userDomainMask,
                                          appropriateFor: nil,
                                          create: true)
      .appendingPathComponent(Bundle.main.bundleIdentifier!)
      .appendingPathComponent("IconCache")

    if !FileManager.default.fileExists(atPath: url.path) {
      try FileManager.default.createDirectory(at: url,
                                              withIntermediateDirectories: false,
                                              attributes: nil)
    }

    return url
  }
}
