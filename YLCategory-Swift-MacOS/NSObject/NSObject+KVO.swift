//
//  NSObject+KVO.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/25.
//

import Foundation

fileprivate var KVOHandlerKey = false

open class KVO: NSObject {
    
    // MARK: kvo回调
    var kvoHandler: ((String, Any?, Any?) -> Void)? {
        get { objc_getAssociatedObject(self, &KVOHandlerKey) as? (String, Any?, Any?) -> Void }
        set { objc_setAssociatedObject(self, &KVOHandlerKey, newValue, .OBJC_ASSOCIATION_COPY_NONATOMIC)}
    }
    
    // MARK: 开启｜关闭kvo
    func kvo(_ enable: Bool) {
        if enable {
            for key in getAllProperties(of: type(of: self)) {
                addObserver(self, forKeyPath: key, options: [.new, .old], context: nil)
            }
        } else {
            for key in getAllProperties(of: type(of: self)) {
                removeObserver(self, forKeyPath: key)
            }
        }
    }
    
    // MARK: KVO 回调处理
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let keyPath = keyPath, getAllProperties(of: type(of: self)).contains(keyPath) else { return }
        let newValue = change?[.newKey]
        let oldValue = change?[.oldKey]
        kvoHandler?(keyPath, newValue, oldValue)
    }
    
    // MARK: - 获取所有属性
    private func getAllProperties(of cls: AnyClass) -> [String] {
        guard cls != NSObject.self else { return [] }
        var properties = [String]()
        var count: UInt32 = 0
        
        // 获取属性列表
        if let ivars = class_copyIvarList(cls, &count) {
            for i in 0..<Int(count) {
                let ivar = ivars[i]
                if let name = ivar_getName(ivar) {
                    properties.append(String(cString: name))
                }
            }
            free(ivars)
        }
        
        // 递归获取父类的属性
        if let superclass = cls.superclass() {
            let superclassProperties = getAllProperties(of: superclass)
            properties.append(contentsOf: superclassProperties)
        }
        return properties
    }
}
