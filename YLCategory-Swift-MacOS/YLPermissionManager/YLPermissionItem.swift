//
//  YLPermissionItem.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/29.
//

import Foundation
import AppKit

class YLPermissionItem: NSView {
    
    convenience init(model: YLPermissionModel) {
        self.init()
        self.model = model
        loadItemInfo()
    }
    
    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        addSubview(iconView)
        addSubview(checkBtn)
        addSubview(infoLabel)
        addSubview(authBtn)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    override var isFlipped: Bool { true }
    
    private lazy var iconView: NSImageView = {
        let iconView = NSImageView()
        iconView.imageScaling = .scaleProportionallyUpOrDown
        return iconView
    }()
    private lazy var checkBtn: NSButton = {
        let btn = NSButton(checkboxWithTitle: "", target: self, action: #selector(checkBtnClick))
        return btn
    }()
    private lazy var infoLabel: NSTextField = {
        let infoLabel = NSTextField(labelWithString: "")
        infoLabel.font = .systemFont(ofSize: 10)
        infoLabel.textColor = .lightGray
        return infoLabel
    }()
    private lazy var authBtn: NSButton = {
        let btn = NSButton(title: YLPermissionManager.localize("Authorize"), target: self, action: #selector(authBtnClick))
        btn.bezelColor = .controlAccentColor
        return btn
    }()
    
    override func layout() {
        super.layout()
        
        var iconFrame = NSRect(x: 0, y: 0, width: 20, height: 20)
        iconFrame.origin.y = frame.size.height / 2 - 25
        iconView.frame = iconFrame
        
        checkBtn.sizeToFit()
        let checkOrigin = NSPoint(x: iconFrame.maxX + 10, y: iconFrame.midY - checkBtn.frame.size.height / 2)
        checkBtn.frame = NSRect(origin: checkOrigin, size: checkBtn.frame.size)
        
        infoLabel.sizeToFit()
        let infoOrigin = NSPoint(x: checkOrigin.x, y: frame.size.height / 2 + 5)
        infoLabel.frame = NSRect(origin: infoOrigin, size: infoLabel.frame.size)
        
        authBtn.sizeToFit()
        let authOrigin = NSPoint(x: frame.size.width - authBtn.frame.size.width, y: frame.size.height / 2 - authBtn.frame.size.height / 2)
        authBtn.frame = NSRect(origin: authOrigin, size: authBtn.frame.size)
    }
    
    // MARK: -
    
    var model: YLPermissionModel!
    
    private func loadItemInfo() {
        switch model.authType {
        case .accessibility:
            // 辅助功能
            iconView.image = bundleImage("Accessbility@2x.png")
            checkBtn.title = YLPermissionManager.localize("Accessibility permission authorization")
        case .fullDisk:
            // 完全磁盘
            iconView.image = bundleImage("Folder@2x.png")
            checkBtn.title = YLPermissionManager.localize("Full disk access authorization")
        case .screenCapture:
            // 录屏
            iconView.image = bundleImage("ScreenRecording@2x.png")
            checkBtn.title = YLPermissionManager.localize("Screen recording permission authorization")
        default: break
        }
        if !model.desc.isEmpty {
            infoLabel.stringValue = "*" + model.desc
        }
        refreshStatus()
    }
    
    private func bundleImage(_ name: String) -> NSImage {
        var url = Bundle.main.url(forResource: "YLPermissionManager", withExtension: "bundle")
        if url == nil {
            url = Bundle.main.url(forResource: "Frameworks", withExtension: nil)?.appendingPathExtension("/YLCategory.framework")
            if url != nil {
                let bundle = Bundle(url: url!)
                url = bundle?.url(forResource: "YLPermissionManager", withExtension: "bundle")
            }
        }
        guard let url = url, let path = Bundle(url: url)?.bundlePath.appending("/\(name)") else { return NSImage() }
        return NSImage(contentsOfFile: path) ?? NSImage()
    }
    
    // MARK: 刷新状态
    @discardableResult
    func refreshStatus() -> Bool {
        var flag = false
        switch model.authType {
        case .accessibility:    flag = YLPermissionManager.shared.getPrivacyAccessibilityIsEnabled()
        case .fullDisk:         flag = YLPermissionManager.shared.getFullDiskAccessIsEnabled()
        case .screenCapture:    flag = YLPermissionManager.shared.getScreenCaptureIsEnabled()
        default: break
        }
        if flag {
            checkBtn.state = .on
            authBtn.isHidden = true
        } else {
            checkBtn.state = .off
            authBtn.isHidden = false
        }
        return flag
    }
    
    // MARK: 点击了box
    @objc func checkBtnClick() {
        checkBtn.state = checkBtn.state == .on ? .off : .on
        authBtnClick()
    }
    
    // MARK: 点击了授权
    @objc func authBtnClick() {
        switch model.authType {
        case .accessibility:    YLPermissionManager.shared.openPrivacyAccessibilitySetting()
        case .fullDisk:         YLPermissionManager.shared.openFullDiskAccessSetting()
        case .screenCapture:    YLPermissionManager.shared.openScreenCaptureSetting()
        default: break
        }
    }
}
