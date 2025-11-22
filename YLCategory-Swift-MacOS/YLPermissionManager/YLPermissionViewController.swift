//
//  YLPermissionViewController.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/29.
//

import Foundation
import AppKit

class YLPermissionViewController: NSViewController {
    
    /// 请求权限的类型
    var authTypes: [YLPermissionModel] = [] {
        didSet {
            box.contentView?.subviews.forEach {
                if $0.isKind(of: YLPermissionItem.self) {
                    $0.removeFromSuperview()
                }
            }
            authTypes.forEach { box.contentView?.addSubview(YLPermissionItem(model: $0)) }
            // 重新计算高度
            guard var frame = view.window?.frame else { return }
            frame.size.height = CGFloat(authTypes.count) * itemHeight + CGFloat(authTypes.count + 1) * itemSpace + 180
            view.window?.setFrame(frame, display: true)
            view.needsLayout = true
        }
    }
    /// 所有权限都已开启，回调
    var allAuthPassedHandler: (() -> Void)?
    /// 点击了跳过，回调
    var skipHandler: (() -> Void)?
    /// 点击了退出，回调
    var quitHandler: (() -> Void)?
    
    // MARK: - UI
    
    private var itemHeight = 50.0
    private var itemSpace = 25.0
    private lazy var effectView: NSVisualEffectView = {
        let effectView = NSVisualEffectView()
        effectView.blendingMode = .behindWindow
        return effectView
    }()
    private lazy var titleLabel: NSTextField = {
        let titleLabel = NSTextField(wrappingLabelWithString: String(format: YLPermissionManager.localize("Permission sub Title"), YLPermissionManager.appName))
        titleLabel.font = .systemFont(ofSize: 15)
        titleLabel.alignment = .center
        return titleLabel
    }()
    private lazy var openBtn: NSButton = {
        let btn = NSButton(image: YLPermissionManager.bundleImage("search_finder@2x.png"), target: self, action: #selector(displayInFinder))
        btn.isBordered = false
        btn.image?.isTemplate = true
        btn.toolTip = YLPermissionManager.localize("Display in Finder")
        return btn
    }()
    private lazy var box: YLPermissionBoxView = {
        let box = YLPermissionBoxView()
        return box
    }()
    private lazy var lookBtn: NSButton = {
        let btn = NSButton(title: YLPermissionManager.localize("View permission setting tutorail"), target: self, action: #selector(lookTutorialVideo))
        btn.bezelColor = .controlAccentColor
        btn.isHidden = YLPermissionManager.shared.tutorialLink == nil || YLPermissionManager.shared.tutorialLink!.isEmpty
        return btn
    }()
    private lazy var quitBtn: NSButton = {
        NSButton(title: YLPermissionManager.localize("Quit App"), target: self, action: #selector(quitApp))
    }()
    private lazy var skipBtn: NSButton = {
        NSButton(title: YLPermissionManager.localize("Skip"), target: self, action: #selector(skip))
    }()
    
    override func loadView() {
        view = YLPermissionView(frame: NSRect(x: 0, y: 0, width: 600, height: 300))
        view.addSubview(effectView)
        view.addSubview(titleLabel)
        view.addSubview(openBtn)
        view.addSubview(box)
        view.addSubview(lookBtn)
        view.addSubview(quitBtn)
        view.addSubview(skipBtn)
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        effectView.frame = view.bounds
        
        openBtn.frame = NSRect(x: view.frame.size.width - 26, y: 8, width: 18, height: 18)
        
        let size = titleLabel.sizeThatFits(NSMakeSize(view.frame.size.width - 80, CGFloat.greatestFiniteMagnitude))
        let titleOrigin = NSMakePoint(view.frame.size.width / 2 - size.width / 2, 60)
        titleLabel.frame = NSRect(origin: titleOrigin, size: size)
        
        box.frame = NSMakeRect(40, titleLabel.frame.maxY + 20, view.frame.size.width - 80, CGFloat(authTypes.count) * itemHeight + CGFloat(authTypes.count + 1) * itemSpace)
        
        var top = itemSpace
        for item in box.contentView!.subviews.reversed() where item.isKind(of: YLPermissionItem.self) {
            guard let permissionItem = item as? YLPermissionItem else { continue }
            permissionItem.frame = NSMakeRect(30, top, box.contentView!.frame.size.width - 60, itemHeight)
            top = permissionItem.frame.maxY + itemSpace
        }
        
        lookBtn.sizeToFit()
        quitBtn.sizeToFit()
        skipBtn.sizeToFit()
        
        let lookOrigin = NSMakePoint(box.frame.origin.x, box.frame.maxY + 10)
        lookBtn.frame = NSRect(origin: lookOrigin, size: lookBtn.frame.size)
        
        let skipOrigin = NSMakePoint(box.frame.maxX - skipBtn.frame.size.width + 5, lookOrigin.y)
        skipBtn.frame = NSRect(origin: skipOrigin, size: skipBtn.frame.size)
        
        let quitOrigin = NSMakePoint(skipOrigin.x - quitBtn.frame.size.width + 5, lookOrigin.y)
        quitBtn.frame = NSRect(origin: quitOrigin, size: quitBtn.frame.size)
    }
    
    
    // MARK: 刷新所有的授权状态
    func refreshAllAuthState() {
        var all = true
        for item in box.contentView!.subviews where item.isKind(of: YLPermissionItem.self) {
            if let permissionItem = item as? YLPermissionItem {
                all = permissionItem.refreshStatus() && all
            }
        }
        if all {
            allAuthPassedHandler?()
        }
    }
    
    // MARK: -
    
    // MARK: 在"访达"中显示
    
    @objc func displayInFinder() {
        NSWorkspace.shared.activateFileViewerSelecting([URL(fileURLWithPath: Bundle.main.bundlePath)])
    }
    
    // MARK: 观看权限设置教学
    @objc func lookTutorialVideo() {
        guard let link = YLPermissionManager.shared.tutorialLink,
              let url = URL(string: link) else { return }
        NSWorkspace.shared.open(url)
    }
    // MARK: 退出app
    @objc func quitApp() {
        quitHandler?()
        NSApp.terminate(nil)
    }
    // MARK: 忽略
    @objc func skip() {
        skipHandler?()
    }
    
#if DEBUG
    deinit {
        print("YLPermissionViewController deinit")
    }
#endif
    
}


fileprivate class YLPermissionBoxView: NSBox {
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        boxType = .custom
        titlePosition = .noTitle
        cornerRadius = 15
        borderWidth = 0
        contentViewMargins = .zero
        adjustBackground()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidChangeEffectiveAppearance() {
        super.viewDidChangeEffectiveAppearance()
        adjustBackground()
    }
    
    func adjustBackground() {
        if NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua {
            fillColor = NSColor(white: 0, alpha: 0.15)
        } else {
            fillColor = NSColor(white: 1, alpha: 0.4)
        }
    }
}

fileprivate class YLPermissionView: NSView {
    override var isFlipped: Bool { true }
}
