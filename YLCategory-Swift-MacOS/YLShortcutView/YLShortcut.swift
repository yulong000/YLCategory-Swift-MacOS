//
//  YLShortcut.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/1/6.
//

import Foundation
import Carbon
import AppKit

public class YLShortcut: NSObject, NSSecureCoding, NSCopying {
    
    /// 按键
    public private(set) var keyCode: UInt16
    /// 修饰键
    public private(set) var modifierFlags: NSEvent.ModifierFlags
    
    // MARK: - 构造方法
    
    public init(keyCode: UInt16, modifierFlags: NSEvent.ModifierFlags) {
        self.keyCode = keyCode
        self.modifierFlags = modifierFlags.intersection([.control, .shift, .command, .option, .function])
    }
    
    public convenience init(event: NSEvent) {
        self.init(keyCode: event.keyCode, modifierFlags: event.modifierFlags)
    }
    
    // MARK: - 常用字符串获取
    
    // MARK: 按键字符串, eg: `5` in `⌘5`
    public var keyCodeString: String {
        let code = Int(keyCode)
        switch code {
        case NSNotFound:                return ""
        case kVK_F1:                    return "F1"
        case kVK_F2:                    return "F2"
        case kVK_F3:                    return "F3"
        case kVK_F4:                    return "F4"
        case kVK_F5:                    return "F5"
        case kVK_F6:                    return "F6"
        case kVK_F7:                    return "F7"
        case kVK_F8:                    return "F8"
        case kVK_F9:                    return "F9"
        case kVK_F10:                   return "F10"
        case kVK_F11:                   return "F11"
        case kVK_F12:                   return "F12"
        case kVK_F13:                   return "F13"
        case kVK_F14:                   return "F14"
        case kVK_F15:                   return "F15"
        case kVK_F16:                   return "F16"
        case kVK_F17:                   return "F17"
        case kVK_F18:                   return "F18"
        case kVK_F19:                   return "F19"
        case kVK_Space:                 return "Space"
        case kVK_Escape:                return "⎋"
        case kVK_Delete:                return "⌫"
        case kVK_ForwardDelete:         return "⌦"
        case kVK_LeftArrow:             return "←"
        case kVK_RightArrow:            return "→"
        case kVK_UpArrow:               return "↑"
        case kVK_DownArrow:             return "↓"
        case kVK_Help:                  return "Help"
        case kVK_Home:                  return "Home"
        case kVK_End:                   return "End"
        case kVK_PageUp:                return "PageUp"
        case kVK_PageDown:              return "PageDown"
        case kVK_Tab:                   return "⇥"
        case kVK_Return:                return "↩︎"
        
        case kVK_ANSI_Keypad0:          return "0"
        case kVK_ANSI_Keypad1:          return "1"
        case kVK_ANSI_Keypad2:          return "2"
        case kVK_ANSI_Keypad3:          return "3"
        case kVK_ANSI_Keypad4:          return "4"
        case kVK_ANSI_Keypad5:          return "5"
        case kVK_ANSI_Keypad6:          return "6"
        case kVK_ANSI_Keypad7:          return "7"
        case kVK_ANSI_Keypad8:          return "8"
        case kVK_ANSI_Keypad9:          return "9"
        case kVK_ANSI_KeypadDecimal:    return "."
        case kVK_ANSI_KeypadMultiply:   return "*"
        case kVK_ANSI_KeypadDivide:     return "/"
        case kVK_ANSI_KeypadPlus:       return "+"
        case kVK_ANSI_KeypadMinus:      return "-"
        case kVK_ANSI_KeypadEquals:     return "="
        case kVK_ANSI_KeypadClear:      return "⌧"
        case kVK_ANSI_KeypadEnter:      return "⏎"
        default:
            break
        }
        
        var keystroke: String? = nil
        var error: OSStatus = noErr
        
        // 获取当前 ASCII 可用的键盘布局
        if let inputSource = TISCopyCurrentASCIICapableKeyboardLayoutInputSource()?.takeRetainedValue(),
           let layoutData = TISGetInputSourceProperty(inputSource, kTISPropertyUnicodeKeyLayoutData) {
            // 获取键盘布局数据
            let dataRef = unsafeBitCast(layoutData, to: CFData.self)
            let keyLayout = unsafeBitCast(CFDataGetBytePtr(dataRef), to: UnsafePointer<CoreServices.UCKeyboardLayout>.self)
            var chars = [UniChar](repeating: 0, count: 256)
            var length: Int = 0
            var deadKeyState: UInt32 = 0
            
            // 翻译 keyCode 为字符
            error = UCKeyTranslate(keyLayout,
                                   keyCode,
                                   UInt16(kUCKeyActionDisplay),
                                   0, // 无修饰符
                                   UInt32(LMGetKbdType()),
                                   OptionBits(kUCKeyTranslateNoDeadKeysMask),
                                   &deadKeyState,
                                   chars.count,
                                   &length,
                                   &chars)
            if error == noErr, length > 0 {
                keystroke = String(utf16CodeUnits: chars, count: Int(length))
            }
        }
        
        // 验证 keystroke
        if let keystroke = keystroke, !keystroke.isEmpty {
            let validChars = CharacterSet.alphanumerics.union(.punctuationCharacters).union(.symbols)
            for char in keystroke {
                if !validChars.contains(char.unicodeScalars.first!) {
                    return ""
                }
            }
            return keystroke.uppercased()
        }
        return ""
    }
    
    // MARK: 修饰键字符串, eg: `⌘` in `⌘5`
    public var modifierFlagsString: String {
        var chars = [Character]()
        if modifierFlags.contains(.control) { chars.append("⌃") }
        if modifierFlags.contains(.option) { chars.append("⌥") }
        if modifierFlags.contains(.shift) { chars.append("⇧") }
        if modifierFlags.contains(.command) { chars.append("⌘") }
        return String(chars)
    }
    
    /* 有关“按键等效”的确切含义，请参阅 `NSMenuItem` 的 `keyEquivalent`
    属性。此处的字符串用于支持快捷方式
    验证（“此菜单中的快捷方式是否已被使用？”）和
    在 `NSMenu` 中显示。

    此属性的值可能与 `keyCodeString` 不同。例如
    俄语键盘有一个 `Г` (Ge) 西里尔字符代替
    拉丁语 `U` 键。这意味着您可以创建一个 `^Г` 快捷方式，但在菜单中
    始终显示为 `^U`。因此 `keyCodeString` 返回 `Г`
    而 `keyCodeStringForKeyEquivalent` 返回 `U`。
    */
    /// 用于按键等效匹配的按键代码字符串。
    public var keyCodeStringForKeyEquivalent: String {
        let code = Int(keyCode)
        switch code {
        case kVK_F1:            return "F1"
        case kVK_F2:            return "F2"
        case kVK_F3:            return "F3"
        case kVK_F4:            return "F4"
        case kVK_F5:            return "F5"
        case kVK_F6:            return "F6"
        case kVK_F7:            return "F7"
        case kVK_F8:            return "F8"
        case kVK_F9:            return "F9"
        case kVK_F10:           return "F10"
        case kVK_F11:           return "F11"
        case kVK_F12:           return "F12"
        case kVK_F13:           return "F13"
        case kVK_F14:           return "F14"
        case kVK_F15:           return "F15"
        case kVK_F16:           return "F16"
        case kVK_F17:           return "F17"
        case kVK_F18:           return "F18"
        case kVK_F19:           return "F19"
        case kVK_Space:         return "Space"
        case kVK_Escape:        return "⎋"
        case kVK_Delete:        return "⌫"
        case kVK_ForwardDelete: return "⌦"
        case kVK_LeftArrow:     return "←"
        case kVK_RightArrow:    return "→"
        case kVK_UpArrow:       return "↑"
        case kVK_DownArrow:     return "↓"
        case kVK_Help:          return "Help"
        case kVK_Home:          return "Home"
        case kVK_End:           return "End"
        case kVK_PageUp:        return "PageUp"
        case kVK_PageDown:      return "PageDown"
        case kVK_Tab:           return "⇥"
        case kVK_Return:        return "↩︎"
        default:
            return keyCodeString.lowercased()
        }
    }
    
    public var carbonKeyCode: UInt32 { keyCode == NSNotFound ? 0 : UInt32(keyCode) }
    public var carbonFlags: UInt32 {
        var carbonFlags: Int = 0
        if modifierFlags.contains(.command) { carbonFlags |= cmdKey }
        if modifierFlags.contains(.option) { carbonFlags |= optionKey }
        if modifierFlags.contains(.control) { carbonFlags |= controlKey }
        if modifierFlags.contains(.shift) { carbonFlags |= shiftKey }
        return UInt32(carbonFlags)
    }
    
    
    // MARK: - coding
    
    public static var supportsSecureCoding: Bool { true }
    
    public func encode(with coder: NSCoder) {
        coder.encode(keyCode != NSNotFound ? keyCode : -1, forKey: "keyCode")
        coder.encode(modifierFlags.rawValue, forKey: "modifierFlags")
    }
    
    public required init?(coder: NSCoder) {
        let code = coder.decodeInteger(forKey: "keyCode")
        self.keyCode = UInt16(code < 0 ? NSNotFound : code)
        self.modifierFlags = NSEvent.ModifierFlags(rawValue: UInt(coder.decodeInt64(forKey: "modifierFlags")))
    }
    
    // MARK: - json <-> model
    
    public func toJson() -> Dictionary<String, Any> {
        var json: [String: Any] = [:]
        json["keyCode"] = keyCode
        json["modifierFlags"] = modifierFlags.rawValue
        json["keyCodeString"] = keyCodeString
        json["modifierFlagsString"] = modifierFlagsString
        return json
    }
    
    public convenience init?(json: Dictionary<String, Any>?) {
        guard let json = json,
              let keyCode = json["keyCode"] as? UInt16,
              let modifierFlags = json["modifierFlags"] as? NSEvent.ModifierFlags else { return nil }
        self.init(keyCode: keyCode, modifierFlags: modifierFlags)
    }
    
    // MARK: - copy
    
    public func copy(with zone: NSZone? = nil) -> Any {
        return YLShortcut(keyCode: keyCode, modifierFlags: modifierFlags)
    }
    
    // MARK: - equal
    
    public override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? Self else { return false }
        return keyCode == other.keyCode && modifierFlags == other.modifierFlags
    }
    
    static func == (lhs: YLShortcut, rhs: YLShortcut) -> Bool {
        return lhs.isEqual(rhs)
    }
    
    // MARK: - hash
    
    public override var hash: Int { Int(keyCode) + modifierFlags.rawValue.hashValue }
   
#if DEBUG
    // MARK: 打印
    public override var description: String { "[\(modifierFlagsString) + \(keyCodeString)]" + "~> [\(modifierFlags) + \(keyCode)]" }
#endif
    
}
