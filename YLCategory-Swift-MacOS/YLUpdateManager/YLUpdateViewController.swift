//
//  YLUpdateViewController.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/30.
//

import Foundation
import AppKit

class YLUpdateViewController: NSViewController {
    
    ///  升级信息
    var info: String? {
        didSet {
            infoView.string = info ?? ""
            var height: CGFloat = infoView.string.boundingRect(with: NSSize(width: 460, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : infoView.font!]).size.height
            infoView.frame = NSMakeRect(0, 0, 460, height)
            if #available(macOS 26.0, *) {
                height = min(600, height + 85)
            } else {
                height = min(600, height + 100)
            }
            view.window?.setFrame(NSRect(x: 0, y: 0, width: 500, height: height), display: true)
            view.window?.center()
        }
    }
    // 新的版本号
    var newVersion: String?
    // 是否显示跳过按钮
    var showSkipButton: Bool = true {
        didSet {
            skipBtn.isHidden = !showSkipButton
        }
    }
    
    @objc private func skip() {
        view.window?.close()
        UserDefaults.standard.set(newVersion, forKey: "YLUpdateSkipVersion")
        UserDefaults.standard.synchronize()
    }
    
    @objc private func cancel() {
        view.window?.close()
    }

    @objc private func update() {
        if let appStoreUrl = YLUpdateManager.shared.appStoreUrl {
            NSWorkspace.shared.open(URL(string: appStoreUrl)!)
        }
        view.window?.close()
    }
    
    // MARK: - 布局
    
    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(effectView)
        view.addSubview(scrollView)
        view.addSubview(skipBtn)
        view.addSubview(cancelBtn)
        view.addSubview(updateBtn)
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        effectView.frame = view.bounds
        
        updateBtn.sizeToFit()
        cancelBtn.sizeToFit()
        skipBtn.sizeToFit()
        
        var updateFrame = updateBtn.frame
        updateFrame.origin = NSPoint(x: view.frame.size.width - 20 - updateFrame.size.width, y: 10)
        updateBtn.frame = updateFrame
        
        var cancelFrame = cancelBtn.frame
        cancelFrame.origin = NSPoint(x: updateFrame.minX - cancelFrame.size.width - 5, y: 10)
        cancelBtn.frame = cancelFrame
        
        var skipFrame = skipBtn.frame
        skipFrame.origin = NSPoint(x: 20, y: 10)
        skipBtn.frame = skipFrame
        
        let scrollY = updateFrame.maxY + 10
        scrollView.frame = NSRect(x: 20, y: scrollY, width: view.frame.size.width - 40, height: view.frame.size.height - scrollY - 40)
        
    }
    
    // MARK: - UI
    
    private lazy var effectView: NSVisualEffectView = {
        let effectView = NSVisualEffectView()
        effectView.blendingMode = .behindWindow
        return effectView
    }()
    private lazy var scrollView: NSScrollView = {
        let scrollView = NSScrollView()
        scrollView.hasHorizontalScroller = false
        scrollView.hasVerticalScroller = false
        scrollView.drawsBackground = false
        scrollView.contentInsets = NSEdgeInsetsZero
        scrollView.documentView = infoView
        return scrollView
    }()
    private lazy var infoView: NSTextView = {
        let infoView = NSTextView()
        infoView.font = .systemFont(ofSize: 13)
        infoView.isEditable = false
        infoView.drawsBackground = false
        return infoView
    }()
    
    private lazy var skipBtn: NSButton = {
        NSButton(title: YLUpdateManager.localize("Skip This Version"), target: self, action: #selector(skip))
    }()
    private lazy var cancelBtn: NSButton = {
        NSButton(title: YLUpdateManager.localize("Cancel"), target: self, action: #selector(cancel))
    }()
    private lazy var updateBtn: NSButton = {
        let btn = NSButton(title: YLUpdateManager.localize("Update"), target: self, action: #selector(update))
        btn.bezelColor = .controlAccentColor
        return btn
    }()
    
}
