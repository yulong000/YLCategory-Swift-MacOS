//
//  YLHud.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/1/1.
//

import Foundation
import AppKit

@objc public enum YLHudStyle: UInt8 {
    case auto, black, white
}

public class YLHudWindow: NSWindow {
 
    public override var canBecomeKey: Bool { false }
    public override var canBecomeMain: Bool { false }
    
}

public class YLHud: YLHudWindow {
    
    /// 全局配置
    public static var config = YLHudConfig()
    
    /// 显示的样式
    public var style: YLHudStyle = .auto {
        didSet {
            if style == .auto {
                style = YLHud.getDisplayStyle(style)
            }
            hudView.style = style
            textLabel.textColor = style == .black ? NSColor.white : NSColor.black
        }
    }
    
    // MARK: - 显示
    
    /// 显示成功
    /// - Parameters:
    ///   - text: 文字
    ///   - window: 显示到的窗口
    ///   - delay: 延迟几秒后隐藏
    ///   - completionHandler: 隐藏后的回调
    /// - Returns: hud
    @discardableResult
    public class func showSuccess(_ text: String, to window: NSWindow?, hideAfter delay: CGFloat? = 1, completionHandler: (() -> Void)? = nil) -> YLHud {
        let successView = createSuccessView(style: config.style)
        return showCustomView(successView, text: text, to: window, hideAfter: delay, completionHandler: completionHandler)
    }
    
    /// 显示失败
    /// - Parameters:
    ///   - text: 文字
    ///   - window: 显示到的窗口
    ///   - delay: 延迟几秒后隐藏
    ///   - completionHandler: 隐藏后的回调
    /// - Returns: hud
    @discardableResult
    public class func showError(_ text: String, to window: NSWindow?, hideAfter delay: CGFloat? = 1, completionHandler: (() -> Void)? = nil) -> YLHud {
        let errorView = createErrorView(style: config.style)
        return showCustomView(errorView, text: text, to: window, hideAfter: delay, completionHandler: completionHandler)
    }
    
    /// 显示文本
    /// - Parameters:
    ///   - text: 文字
    ///   - window: 显示到的窗口
    ///   - delay: 延迟几秒后隐藏
    ///   - completionHandler: 隐藏后的回调
    /// - Returns: hud
    @discardableResult
    public class func showText(_ text: String, to window: NSWindow?, hideAfter delay: CGFloat? = 1, completionHandler: (() -> Void)? = nil) -> YLHud {
        return showCustomView(nil, text: text, to: window, hideAfter: delay, completionHandler: completionHandler)
    }
    
    /// 显示加载框（需手动隐藏）
    /// - Parameters:
    ///   - text: 文字
    ///   - window: 显示到的窗口
    /// - Returns: hud
    @discardableResult
    public class func showLoading(_ text: String, to window: NSWindow?) -> YLHud {
        let indicator = createLoadingIndicator()
        return showCustomView(indicator, text: text, to: window, hideAfter: -1)
    }
    
    /// 显示进度 （需手动隐藏）
    /// - Parameters:
    ///   - progress: 0.0 ~ 1,  显示格式为 30%
    ///   - text: 文字
    ///   - window: 显示到的窗口
    /// - Returns: hud
    @discardableResult
    public class func showProgress(_ progress: Float, text: String? = nil, to window: NSWindow?) -> YLHud {
        let progressView = createProgressView(style: config.style)
        progressView.progress = progress
        return showCustomView(progressView, text: text ?? progressView.progressText, to: window, hideAfter: -1)
    }
    
    /// 显示自定义内容
    /// - Parameters:
    ///   - customView: 显示在上部的自定义view，需设置宽高，会自动置顶居中， 传空时只显示文字
    ///   - text: 显示在下部的文字
    ///   - window: 显示到哪个window上，居中显示
    ///   - delay: 多少秒后自动隐藏，小于0 则不隐藏
    ///   - completionHandler: 隐藏后的回调
    /// - Returns: hud
    @discardableResult
    public class func showCustomView(_ customView: NSView?, text: String, to window: NSWindow?, hideAfter delay: CGFloat? = 1.0, completionHandler: (() -> Void)? = nil) -> YLHud {
        guard let toWindow = window ?? NSApp.keyWindow else { return YLHud() }
        
        // 增加一个全覆盖的window，禁用点击其他地方，如果设置为[NSColor clearColor]，鼠标是可以穿透的，所以必须得有个色值
        // Q：为啥不直接设置hud为全覆盖呢？
        // A：因为半透明的window，对其上面的view做动画或者frame更改的时候，会有残影，应该是系统bug，所以简单粗暴，直接再套一层
        let parentWindow = NSWindow()
        parentWindow.backgroundColor = .init(white: 0, alpha: 0.001)
        parentWindow.level = .popUpMenu
        parentWindow.styleMask = .borderless
        parentWindow.setFrame(toWindow.frame, display: true)
        parentWindow.isMovable = false
        parentWindow.isReleasedWhenClosed = false
        toWindow.addChildWindow(parentWindow, ordered: .above)
        
        // 这个是要显示的小窗口
        let hud = YLHud()
        hud.style = config.style
        parentWindow.addChildWindow(hud, ordered: .above)
        hud.textLabel.stringValue = text
        hud.completionHandler = completionHandler
        if let customView = customView {
            hud.customView = customView
            hud.hudView.addSubview(customView)
        }
        hud.layoutUI()
        if let delay = delay, delay >= 0 {
            // 自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                YLHud.hideHUD(hud)
            }
        }
        return hud
    }
    
    // MARK: - 隐藏
    
    /// 隐藏hud
    /// - Parameter window: 隐藏传入window上的hud
    public class func hideHUDForWindow(_ window: NSWindow?) {
        guard let w = window ?? NSApp.keyWindow, let children = w.childWindows, !children.isEmpty else { return }
        for child in children {
            if child.isKind(of: YLHud.self) {
                hideHUD(child as! YLHud)
            } else {
                hideHUDForWindow(child)
            }
        }
    }
    
    /// 隐藏指定的hud
    /// - Parameter hud: 只隐藏该hud
    public class func hideHUD(_ hud: YLHud) {
        guard let parent = hud.parent else {
            hud.close()
            hud.completionHandler?()
            return
        }
        parent.parent?.removeChildWindow(parent)
        parent.removeChildWindow(hud)
        parent.close()
        hud.close()
        hud.completionHandler?()
    }
    
    // MARK: - 实例方法
    
    /// 隐藏hud
    /// - Parameters:
    ///   - delay: 延迟几秒后隐藏
    ///   - completionHandler: 隐藏后的回调
    public func hide(after delay: CGFloat? = nil, completionHandler: (() -> Void)? = nil) {
        self.completionHandler = completionHandler
        if let delay = delay, delay >= 0 {
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                YLHud.hideHUD(self)
            }
        } else {
            YLHud.hideHUD(self)
        }
    }
    
    /// 切换显示加载框
    /// - Parameter text: 文字
    public func showLoading(_ text: String) {
        textLabel.stringValue = text
        layoutUI()
    }
    
    /// 切换显示文本
    /// - Parameters:
    ///   - text: 文字
    ///   - delay: 延迟几秒后隐藏
    ///   - completionHandler: 隐藏后的回调
    public func showText(_ text: String, hideAfter delay: CGFloat? = 1.0, completionHandler: (() -> Void)? = nil) {
        customView?.removeFromSuperview()
        customView = nil
        textLabel.stringValue = text
        self.completionHandler = completionHandler
        layoutUI()
        if let delay = delay, delay >= 0 {
            // 自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                YLHud.hideHUD(self)
            }
        }
    }
    
    /// 切换显示成功
    /// - Parameters:
    ///   - text: 文字
    ///   - delay: 延迟几秒后隐藏
    ///   - completionHandler: 隐藏后的回调
    public func showSuccess(_ text: String, hideAfter delay: CGFloat? = 1.0, completionHandler: (() -> Void)? = nil) {
        customView?.removeFromSuperview()
        customView = YLHud.createSuccessView(style: style)
        hudView.addSubview(customView!)
        textLabel.stringValue = text
        self.completionHandler = completionHandler
        layoutUI()
        if let delay = delay, delay >= 0 {
            // 自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                YLHud.hideHUD(self)
            }
        }
    }
    
    /// 切换显示失败
    /// - Parameters:
    ///   - text: 文字
    ///   - delay: 延迟几秒后隐藏
    ///   - completionHandler: 隐藏后的回调
    public func showError(_ text: String, hideAfter delay: CGFloat? = 1.0, completionHandler: (() -> Void)? = nil) {
        customView?.removeFromSuperview()
        customView = YLHud.createErrorView(style: style)
        hudView.addSubview(customView!)
        textLabel.stringValue = text
        self.completionHandler = completionHandler
        layoutUI()
        if let delay = delay, delay >= 0 {
            // 自动隐藏
            DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
                YLHud.hideHUD(self)
            }
        }
    }
    
    /// 切换显示进度
    /// - Parameters:
    ///   - progress: 进度  0.0 ～ 1, 显示格式为30%
    ///   - text: 文字
    public func showProgress(_ progress: Float, text: String? = nil) {
        if let customView = customView, customView.isKind(of: YLHudProgressView.self) {
            let progressView = customView as! YLHudProgressView
            progressView.progress = progress
            textLabel.stringValue = text ?? progressView.progressText
        } else {
            customView?.removeFromSuperview()
            let progressView = YLHud.createProgressView(style: style)
            progressView.progress = progress
            customView = progressView
            hudView.addSubview(customView!)
            textLabel.stringValue = text ?? progressView.progressText
        }
        layoutUI()
    }
    
    // MARK: - private
    
    private var hudView: YLHudContentView = YLHudContentView()
    private var customView: NSView?
    private var textLabel: NSTextField = {
        let textLabel = NSTextField(wrappingLabelWithString: "")
        textLabel.font = YLHud.config.textFont ?? NSFont.systemFont(ofSize: 16)
        textLabel.preferredMaxLayoutWidth = YLHud.hudMaxWidth - 40
        textLabel.maximumNumberOfLines = 100
        textLabel.textColor = .white
        textLabel.alignment = .center
        return textLabel
    }()
    private var monitor: Any?
    private static let hudMaxWidth: CGFloat = 300.0
    private var completionHandler: (() -> Void)?
    
    private init() {
        super.init(contentRect: .zero, styleMask: [.titled, .fullSizeContentView, .borderless], backing: .buffered, defer: true)
        backgroundColor = .clear
        level = .popUpMenu
        isReleasedWhenClosed = false
        titlebarAppearsTransparent = true
        contentView?.addSubview(hudView)
        hudView.addSubview(textLabel)
        
        if YLHud.config.movable {
            monitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDragged, handler: { [weak self] event in
                if event.window == self?.parent || event.window == self {
                    // 让窗口响应鼠标的拖动
                    guard let parentwindowOrigin = self?.parent?.parent?.frame.origin, let _ = self?.parent?.parent?.isMovable else { return event }
                    self?.parent?.parent?.setFrameOrigin(NSPoint(x: parentwindowOrigin.x + event.deltaX, y: parentwindowOrigin.y - event.deltaY))
                }
                return event
            })
        }
    }
    deinit {
        if let monitor = monitor {
            NSEvent.removeMonitor(monitor)
        }
    }
    
    private func layoutUI() {
        // 上下左右留白 20， text customView 间距 20
        if textLabel.stringValue.isEmpty {
            textLabel.setFrameSize(.zero)
        } else {
            textLabel.setFrameSize(textLabel.sizeThatFits(NSSize(width: YLHud.hudMaxWidth - 40, height: CGFloat.greatestFiniteMagnitude)))
        }
        
        guard let parent = parent else { return }
        
        let windowWidth = parent.frame.size.width
        let windowHeight = parent.frame.size.height
        let windowX = parent.frame.origin.x
        let windowY = parent.frame.origin.y
        let textLabelWidth = textLabel.frame.size.width
        let textLabelHeight = textLabel.frame.size.height
        var hudWidth: CGFloat = 0.0
        var hudHeight: CGFloat = 0.0
        if let customView = customView {
            let customViewWidth = customView.frame.size.width
            let customViewHeight = customView.frame.size.height
            hudWidth = max(textLabelWidth, customViewWidth) + 40
            hudHeight = (textLabelHeight > 0 ? (textLabelHeight + 20) : 0) + customViewHeight + 40
            hudWidth = max(hudWidth, hudHeight)
            hudView.setFrameSize(NSSize(width: hudWidth, height: hudHeight))
            customView.setFrameOrigin(NSPoint(x: (hudWidth - customViewWidth) / 2, y: 20))
            textLabel.setFrameOrigin(NSPoint(x: (hudWidth - textLabelWidth) / 2, y: 20 + customViewHeight + 20))
        } else {
            hudWidth = textLabelWidth + 40
            hudHeight = textLabelHeight + 40
            hudWidth = max(hudWidth, hudHeight)
            hudView.setFrameSize(NSSize(width: hudWidth, height: hudHeight))
            textLabel.setFrameOrigin(NSPoint(x: 20, y: 20))
        }
        let frame = NSRect(x: (windowWidth - hudWidth) / 2 + windowX, y: (windowHeight - hudHeight) / 2 + windowY, width: hudWidth, height: hudHeight)
        setFrame(frame, display: true)
        // hud 居中
        hudView.setFrameOrigin(.zero)
    }
    
    // MARK: 创建成功view
    private class func createSuccessView(style: YLHudStyle) -> NSImageView {
        let successView = NSImageView(frame: NSMakeRect(0, 0, 40, 40))
        successView.tag = 10000
        set(imageView: successView, withStyle: style)
        return successView
    }
    
    // MARK: 创建失败view
    private class func createErrorView(style: YLHudStyle) -> NSImageView {
        let errorView = NSImageView(frame: NSMakeRect(0, 0, 40, 40))
        errorView.tag = 20000
        set(imageView: errorView, withStyle: style)
        return errorView
    }
    
    private class func set(imageView: NSImageView, withStyle style: YLHudStyle) {
        let viewStyle = getDisplayStyle(style)
        if imageView.tag == 10000 {
            // 成功
            imageView.image = viewStyle == .black ? bundleImage("success_white@2x.png") : bundleImage("success_black@2x.png")
        } else if imageView.tag == 20000 {
            // 失败
            imageView.image = viewStyle == .black ? bundleImage("error_white@2x.png") : bundleImage("error_black@2x.png")
        }
    }
    
    // MARK: 创建loading
    private class func createLoadingIndicator() -> NSProgressIndicator {
        let indicator = NSProgressIndicator(frame: NSRect(x: 0, y: 0, width: 40, height: 40))
        indicator.style = .spinning
        if let filter = createColorFilter(style: config.style) {
            indicator.contentFilters = [filter]
        }
        indicator.startAnimation(nil)
        return indicator
    }
    
    private class func createColorFilter(style: YLHudStyle) -> CIFilter? {
        let colorStyle = getDisplayStyle(style)
        let color: NSColor = colorStyle == .white ? NSColor.black.usingColorSpace(.deviceRGB)! : NSColor.white.usingColorSpace(.deviceRGB)!
        let min = CIVector(x: color.redComponent, y: color.greenComponent, z: color.blueComponent, w: 0)
        let max = CIVector(x: color.redComponent, y: color.greenComponent, z: color.blueComponent, w: 1.0)
        let colorFilter = CIFilter(name: "CIColorClamp")
        colorFilter?.setDefaults()
        colorFilter?.setValue(min, forKey: "inputMinComponents")
        colorFilter?.setValue(max, forKey: "inputMaxComponents")
        return colorFilter
    }
    
    // MARK: 创建一个进度
    private class func createProgressView(style: YLHudStyle) -> YLHudProgressView {
        let progressStyle = getDisplayStyle(style)
        let progressView = YLHudProgressView(frame: NSRect(x: 0, y: 0, width: 40, height: 40))
        progressView.style = progressStyle
        return progressView
    }
    
    private class func getDisplayStyle(_ style: YLHudStyle) -> YLHudStyle {
        var displayStyle: YLHudStyle = .black
        if style == .auto, NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            displayStyle = .white
        }
        return displayStyle
    }
    
    // MARK: 获取 Bundle 里面的图片
    private class func bundleImage(_ imageName: String) -> NSImage {
        var url = Bundle.main.url(forResource: "YLHud", withExtension: "bundle")
        if url == nil {
            if let bundleUrl = Bundle.main.url(forResource: "Frameworks", withExtension: nil)?.appendingPathComponent("YLCategory").appendingPathExtension("framework"),
               let bundle = Bundle(url: bundleUrl) {
                url = bundle.url(forResource: "YLHud", withExtension: "bundle")
            }
        }
        guard let bundleUrl = url,
              let path = Bundle(url: bundleUrl)?.bundlePath.appendingFormat("/\(imageName)"),
              let image = NSImage(contentsOfFile: path) else { return NSImage() }
        return image
    }
}

// MARK: - 样式配置

public struct YLHudConfig {
    
    /// 显示的样式
    public var style: YLHudStyle = .auto
    /// 显示的文字的字体
    public var textFont: NSFont? = nil
    /// 是否可以通过拖动移动背后的window
    public var movable: Bool = true
    
}

// MARK: - 内容显示区域

public class YLHudContentView: NSView {
    
    /// 样式
    var style: YLHudStyle = .black {
        didSet {
            visualEffectView.appearance = NSAppearance(named: style == .black ? .vibrantDark : .vibrantLight)
        }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        wantsLayer = true
        layer?.cornerRadius = 10
        addSubview(visualEffectView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layout() {
        super.layout()
        visualEffectView.frame = bounds
    }
    public override var isFlipped: Bool { true }
    
    
    private lazy var visualEffectView: NSVisualEffectView = {
        let effectView = NSVisualEffectView()
        effectView.state = .active
        effectView.blendingMode = .withinWindow
        effectView.appearance = NSAppearance(named: .vibrantDark)
        return effectView
    }()
}

// MARK: - 进度

public class YLHudProgressView: NSView {
    
    /// 样式
    var style: YLHudStyle = .auto {
        didSet { needsDisplay = true }
    }
    /// 进度
    var progress: Float = 0.0 {
        didSet {
            // 限制 progress 在 0 到 1 之间
            progress = min(1, max(0, progress))
            progressText = "\(Int(progress * 100))%"
            needsDisplay = true
        }
    }
    /// 将progress转换成百分比字符串
    private(set) var progressText: String = ""
    
    
    public override var isFlipped: Bool { true }
    
    public override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        
        guard let ctx = NSGraphicsContext.current?.cgContext else {
            return
        }
        
        ctx.setLineWidth(2)
        
        if style == .black {
            NSColor.white.set()
        } else {
            NSColor.black.set()
        }
        
        let centerX = bounds.midX
        let centerY = bounds.midY
        let radius1 = bounds.height / 2 - 2
        let radius2 = radius1 - 3
        
        // 外层的圆
        ctx.addArc(center: CGPoint(x: centerX, y: centerY),
                   radius: radius1,
                   startAngle: 0,
                   endAngle: CGFloat.pi * 2,
                   clockwise: false)
        ctx.strokePath()
        
        // 内部的进度
        let end = CGFloat.pi * 2 * CGFloat(progress) - CGFloat.pi / 2
        ctx.addArc(center: CGPoint(x: centerX, y: centerY),
                   radius: radius2,
                   startAngle: -CGFloat.pi / 2,
                   endAngle: end,
                   clockwise: false)
        ctx.addLine(to: CGPoint(x: centerX, y: centerY))
        ctx.addLine(to: CGPoint(x: centerX, y: centerY - radius2))
        ctx.fillPath()
    }
}
