//
//  YLShortcutView.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/1/4.
//

import Foundation
import AppKit
import Carbon

open class YLShortcutView: NSView {
    
    /// 快捷键
    open var shortcut: YLShortcut? {
        didSet {
            needsDisplay = true
        }
    }
    /// 快捷键发生变化
    open var changedHandler: ((YLShortcutView, YLShortcut?) -> Void)?
    /// 样式
    open var config: YLShortcutConfig? {
        didSet {
            needsDisplay = true
        }
    }
    
    public override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        initialize()
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        initialize()
    }
    
    // MARK: - private
    
    // MARK: 初始化
    func initialize() {
        addSubview(shortcutBtn)
        addSubview(recoverBtn)
        addSubview(clearBtn)
    }
    
    open override func layout() {
        super.layout()
        let width = frame.size.width
        let height = frame.size.height
        let btnSize = NSSize(width: 12, height: 15)
        var clearFrame = NSZeroRect
        clearFrame.size = btnSize
        clearFrame.origin.y = (height - btnSize.height) / 2
        clearFrame.origin.x = width - btnSize.width - 3
        var recoverFrame = clearFrame
        recoverFrame.origin.x = clearFrame.origin.x - btnSize.width
        recoverBtn.frame = recoverFrame
        clearBtn.frame = clearFrame
        shortcutBtn.sizeToFit()
        shortcutBtn.frame = NSRect(x: -7, y: (height - shortcutBtn.frame.size.height) / 2, width: width + 14, height: shortcutBtn.frame.size.height)
    }
    
    deinit {
        removeMonitors()
    }
    
    private func addMonitors() {
        let keyMonitor = NSEvent.addLocalMonitorForEvents(matching: [.flagsChanged, .keyDown]) { [weak self] event in
            guard let self = self else { return event }
            if self.recording {
                let shortcut = YLShortcut(event: event)
                if !shortcut.modifierFlags.isEmpty {
                    // 按下了控制键
                    if shortcut.keyCode == kVK_Delete || shortcut.keyCode == kVK_ForwardDelete {
                        // 删除键，删除快捷键
                        self.clearShortcut()
                        return nil
                    }
                    if shortcut.keyCode == kVK_Escape {
                        // esc，退出编辑
                        self.recoverShortcut()
                        return nil
                    }
                    if shortcut.modifierFlags == NSEvent.ModifierFlags.command &&
                        (shortcut.keyCode == kVK_ANSI_W || shortcut.keyCode == kVK_ANSI_Q) {
                        // cmd + W, cmd + Q
                        self.recoverShortcut()
                        return event
                    }
                    if !shortcut.keyCodeString.isEmpty {
                        // 字母键已按下
                        if YLShortcutManager.shared.valid(shortcut) {
                            // 快捷键有效
                            if YLShortcutManager.shared.alreadyTakenBySystem(shortcut) {
                                // 已经注册过了
                                NSSound.beep()
                                YLHud.showError(YLShortcutManager.localize("Shortcut has been registered by system"), to: self.window)
                                return nil
                            }
                            if YLShortcutManager.shared.validWithOptionModifier(shortcut) == false {
                                // 含有Option，且在当前系统无效，需要打开辅助功能权限
                                self.recording = false
                                NSApp.activate(ignoringOtherApps: true)
                                let alert = NSAlert()
                                alert.alertStyle = .warning
                                alert.messageText = YLShortcutManager.localize("Kind tips")
                                alert.informativeText = YLShortcutManager.localize("Accessibility Tips")
                                alert.addButton(withTitle: YLShortcutManager.localize("To Authorize"))
                                alert.addButton(withTitle: YLShortcutManager.localize("Cancel"))
                                if alert.runModal() == .alertFirstButtonReturn {
                                    // 模拟鼠标抬起，请求辅助功能权限
                                    YLShortcutManager.shared.requestAccessibilityPermission()
                                }
                                return nil
                            } else {
                                if let s = self.shortcut {
                                    // 取消注册之前的快捷键
                                    YLShortcutManager.shared.unregister(s)
                                }
                                self.shortcut = shortcut
                                self.recording = false
                                self.changedHandler?(self, shortcut)
                                return nil
                            }
                        } else {
                            NSSound.beep()
                            YLHud.showError(YLShortcutManager.localize("Control keys are unavailable"), to: self.window)
                        }
                    } else {
                        self.setShortcutButton(title: shortcut.modifierFlagsString, toolTip: nil)
                    }
                } else {
                    // 未按下控制键
                    self.updateBtnTitle()
                }
            }
            return event
        }
        let localMouseMonitor = NSEvent.addLocalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            // 点击在app内，其他地方，恢复快捷键
            guard let self = self else { return event }
            if NSPointInRect(event.locationInWindow, convert(self.bounds, to: nil)) == false {
                self.recoverShortcut()
            }
            return event
        }
        let globalMouseMonitor = NSEvent.addGlobalMonitorForEvents(matching: .leftMouseDown) { [weak self] event in
            // 点击在app外，恢复快捷键
            self?.recoverShortcut()
        }
        monitorArr.append(keyMonitor)
        monitorArr.append(localMouseMonitor)
        monitorArr.append(globalMouseMonitor)
        if let shortcut = shortcut {
            YLShortcutManager.shared.pauseMonitor(shortcut)
        }
    }
    
    private func removeMonitors() {
        monitorArr.forEach { element in
            if let monitor = element {
                NSEvent.removeMonitor(monitor)
            }
        }
        monitorArr.removeAll()
        if let _ = shortcut {
            YLShortcutManager.shared.continueMonitorAllShortcuts()
        }
    }
    
    open override func updateLayer() {
        super.updateLayer()
        updateBtnsImage()
        updateBtnTitle()
    }
    
    private func updateBtnsImage() {
        let style = config?.style ?? YLShortcutManager.shared.config.style
        var dark = true
        switch style {
        case .system:
            dark = NSApp.effectiveAppearance.bestMatch(from: [.darkAqua, .aqua]) == .darkAqua
        case .light:
            dark = false
        case .dark:
            dark = true
        }
        if dark {
            recoverBtn.image = YLShortcutView.bundleImage("shortcut_recover_white_icon@2x.png")
            clearBtn.image = YLShortcutView.bundleImage("shortcut_close_white_icon@2x.png")
        } else {
            recoverBtn.image = YLShortcutView.bundleImage("shortcut_recover_black_icon@2x.png")
            clearBtn.image = YLShortcutView.bundleImage("shortcut_close_black_icon@2x.png")
        }
    }
    
    private func updateBtnTitle() {
        let config = config ?? YLShortcutManager.shared.config
        var title: String = ""
        var toolTip: String = ""
        if recording {
            title = shortcut == nil ? config.titleForEmptyAndEditing : (shortcut!.modifierFlagsString + shortcut!.keyCodeString)
            toolTip = title
        } else {
            title = shortcut == nil ? config.titleForEmpty : (shortcut!.modifierFlagsString + shortcut!.keyCodeString)
            toolTip = YLShortcutManager.localize("Click to edit")
        }
        setShortcutButton(title: title, toolTip: toolTip)
    }
    
    private func setShortcutButton(title: String, toolTip: String?) {
        let config = config ?? YLShortcutManager.shared.config
        let attributes: [NSAttributedString.Key : Any] = [
            .font: config.titleFont,
            .foregroundColor : recording ? NSColor.placeholderTextColor : NSColor.labelColor
        ]
        shortcutBtn.attributedTitle = NSAttributedString(string: title, attributes: attributes)
        if toolTip != nil {
            shortcutBtn.toolTip = toolTip
        }
    }
    
    
    @objc func beginEdit(_ button: NSButton) {
        recording = !recording
    }
    
    @objc func recoverShortcut() {
        recording = false
    }
    
    @objc func clearShortcut() {
        if let shortcut = shortcut {
            // 取消注册之前的快捷键
            YLShortcutManager.shared.unregister(shortcut)
            self.shortcut = nil
            changedHandler?(self, nil)
        }
        recording = false
    }
    
    lazy var shortcutBtn: NSButton = {
        let btn = NSButton(title: "", target: self, action: #selector(beginEdit(_:)))
        btn.state = .off
        return btn
    }()
    lazy var recoverBtn: NSButton = {
        let btn = NSButton(image: YLShortcutView.bundleImage("shortcut_recover_white_icon@2x.png"), target: self, action: #selector(recoverShortcut))
        btn.toolTip = YLShortcutManager.localize("End editing")
        btn.isBordered = false
        btn.isHidden = true
        return btn
    }()
    lazy var clearBtn: NSButton = {
        let btn = NSButton(image: YLShortcutView.bundleImage("shortcut_close_white_icon@2x.png"), target: self, action: #selector(clearShortcut))
        btn.isBordered = false
        btn.isHidden = true
        btn.toolTip = YLShortcutManager.localize("Delete shortcut")
        return btn
    }()
    lazy var monitorArr: [Any?] = []
    /// 是否正在编辑
    var recording = false {
        didSet {
            updateBtnTitle()
            if recording {
                shortcutBtn.state = .on
                clearBtn.isHidden = false
                recoverBtn.isHidden = false
                window?.makeFirstResponder(shortcutBtn)
                addMonitors()
            } else {
                shortcutBtn.state = .off
                clearBtn.isHidden = true
                recoverBtn.isHidden = true
                window?.makeFirstResponder(nil)
                removeMonitors()
            }
        }
    }
    
    // MARK: - 获取图片
    
    static func bundleImage(_ name: String) -> NSImage {
        var url = Bundle.main.url(forResource: "YLShortcutManager", withExtension: "bundle")
        if url == nil {
            url = Bundle.main.url(forResource: "Frameworks", withExtension: nil)?.appendingPathComponent("YLCategory").appendingPathExtension("framework")
            if url != nil, let bundle = Bundle(url: url!) {
                url = bundle.url(forResource: "YLShortcutManager", withExtension: "bundle")
            }
        }
        guard let url = url,
              let path = Bundle(url: url)?.bundlePath.appending("/\(name)"),
              let image = NSImage.init(contentsOfFile: path) else { return NSImage() }
        return image
    }
    
}
