import Cocoa

protocol AppearanceAware {
  var titleLabel: NSTextField { get }
  var subtitleLabel: NSTextField { get }
  var view: NSView { get }
  func update(with appearance: Application.Appearance, duration: TimeInterval, then handler: (() -> Void)?)
}

extension AppearanceAware {
  func update(with appearance: Application.Appearance, duration: TimeInterval = 0, then handler: (() -> Void)? = nil) {
    if duration > 0 {
      NSAnimationContext.current.allowsImplicitAnimation = true
      NSAnimationContext.runAnimationGroup({ (context) in
        context.duration = duration
        switch appearance {
        case .dark:
            view.animator().layer?.backgroundColor = NSColor(named: "Dark")?.cgColor
          titleLabel.animator().textColor = .white
          subtitleLabel.animator().textColor = .controlAccentColor
          view.layer?.borderWidth = 0.0
        case .system:
          view.animator().layer?.backgroundColor = NSColor.gray.cgColor
          titleLabel.animator().textColor = .white
          subtitleLabel.animator().textColor = .lightGray
          view.layer?.borderWidth = 0.0
        case .light:
          view.animator().layer?.backgroundColor = .white
          titleLabel.animator().textColor = .black
          subtitleLabel.animator().textColor = .controlAccentColor
          view.layer?.borderColor = NSColor.gray.withAlphaComponent(0.25).cgColor
          view.layer?.borderWidth = 0
        }
      }, completionHandler:{
        handler?()
      })
    } else {
      switch appearance {
      case .dark:
        view.layer?.backgroundColor = NSColor(named: "Dark")?.cgColor
        titleLabel.textColor = .white
        subtitleLabel.textColor = .controlAccentColor
        view.layer?.borderWidth = 0.0
      case .light:
        view.layer?.backgroundColor = NSColor(named: "Light")?.cgColor
        titleLabel.textColor = .black
        subtitleLabel.textColor = .controlAccentColor
        view.layer?.borderColor = NSColor.gray.withAlphaComponent(0.25).cgColor
        view.layer?.borderWidth = 1.0
      case .system:
        switch view.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) {
        case .darkAqua?:
          view.layer?.backgroundColor = NSColor(named: "Dark")?.cgColor
          titleLabel.textColor = .white
          subtitleLabel.textColor = .lightGray
          view.layer?.borderWidth = 0.0
        case .aqua?:
          view.layer?.backgroundColor = NSColor(named: "Light")?.cgColor
          titleLabel.textColor = .black
          subtitleLabel.textColor = .controlAccentColor
          view.layer?.borderColor = NSColor.gray.withAlphaComponent(0.25).cgColor
          view.layer?.borderWidth = 1.0
        default:
          break
        }
      }
    }
  }
}
