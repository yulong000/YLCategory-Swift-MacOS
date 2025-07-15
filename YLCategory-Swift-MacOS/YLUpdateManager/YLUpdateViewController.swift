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
            infoLabel.stringValue = info ?? ""
            let height: CGFloat = infoLabel.stringValue.boundingRect(with: NSSize(width: 460, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : infoLabel.font!]).size.height + 100
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
    
    // MARK: - UI
    
    override func loadView() {
        view = NSView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(effectView)
        view.addSubview(infoLabel)
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
        cancelFrame.origin = NSPoint(x: updateFrame.minX - cancelFrame.size.width, y: 10)
        cancelBtn.frame = cancelFrame
        
        var skipFrame = skipBtn.frame
        skipFrame.origin = NSPoint(x: 20, y: 10)
        skipBtn.frame = skipFrame
        
        let infoY = updateFrame.maxY + 10
        infoLabel.frame = NSRect(x: 20, y: infoY, width: view.frame.size.width - 40, height: view.frame.size.height - infoY - 40)
    }
    
    private lazy var effectView: NSVisualEffectView = {
        let effectView = NSVisualEffectView()
        effectView.blendingMode = .behindWindow
        return effectView
    }()
    private lazy var infoLabel: NSTextField = {
        let infoLabel = NSTextField(wrappingLabelWithString: "")
        infoLabel.font = .systemFont(ofSize: 13)
        infoLabel.controlSize = .regular
        return infoLabel
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
