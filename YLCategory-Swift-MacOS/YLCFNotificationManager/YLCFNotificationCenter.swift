//
//  YLCFNotificationCenter.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/27.
//

import Foundation

public class YLCFNotificationCenter {
    
    public static var shared = YLCFNotificationCenter()
    private init() {}
    deinit {
        removeAllObservers()
    }
    
    // MARK: - 单向发送
    
    // MARK: 添加通知，block回调
    public func addObserver(_ observer: AnyObject, name: Notification.Name, handler: @escaping ([String: Any]?) -> Void) {
        _addObserver(observer, name: name, handler: handler)
    }
    
    // MARK: 添加通知，selector回调
    public func addObserver(_ observer: AnyObject, name: Notification.Name, selector: Selector) {
        _addObserver(observer, name: name, selector: selector)
    }
    
    // MARK: 发送通知
    public func postCFNotification(_ name: Notification.Name, userInfo: [String : Any]? = nil) {
        let info = (isSandbox ? nil : userInfo) as CFDictionary?
        let notificationName = CFNotificationName(name.rawValue as CFString)
        CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDistributedCenter(), notificationName, nil, info, kCFNotificationDeliverImmediately | kCFNotificationPostToAllSessions)
    }
    
    // MARK: - 发送 + 接受
    
    /// 添加通知，接收到通知后回复
    /// - Parameters:
    ///   - observer: 监听的对象
    ///   - name: 通知名
    ///   - handler: 收到通知后，发送回复信息
    public func addObserver(_ observer: AnyObject, name: Notification.Name, response handler: @escaping ([String : Any]?, ([String : Any]?) -> Void) -> Void) {
        _addObserver(observer, name: name, response: handler)
    }
    
    /// 发送通知，并等待接收通知
    /// - Parameters:
    ///   - name: 通知名
    ///   - userInfo: 发送到信息
    ///   - observer: 回调接收对象，传nil则不会回调
    ///   - handler: 对方收到通知后的回调
    public func postCFNotification(_ name: Notification.Name, userInfo: [String : Any]? = nil, observer: AnyObject, handler: ([String : Any]) -> Void) {
        let info = (isSandbox ? nil : userInfo) as CFDictionary?
        let notificationName = CFNotificationName(name.rawValue as CFString)
        CFNotificationCenterPostNotificationWithOptions(CFNotificationCenterGetDistributedCenter(), notificationName, nil, info, kCFNotificationDeliverImmediately | kCFNotificationPostToAllSessions)
        _addObserver(observer, name: Notification.Name(name.rawValue + YLCFNotificationCallbackNameSuffix), response:  { info, callback in
            callback(info)
        })
    }
    
    // MARK: - 移除
    
    // MARK: 移除某个监听对象
    public func removeObserver(_ observer: AnyObject, name: Notification.Name? = nil) {
        
        guard let notiName = name?.rawValue else {
            // 移除传入对象的所有通知
            observerDict.keys.forEach { ele in
                removeObserver(observer, name: Notification.Name(ele))
            }
            return
        }
        
        // 移除传入对象的传入的通知名
        guard var arr = observerDict[notiName] else { return }
        arr.removeAll { $0 === observer || $0.observer == nil }
        if arr.isEmpty {
            observerDict.removeValue(forKey: notiName)
            CFNotificationCenterRemoveObserver(CFNotificationCenterGetDistributedCenter(), Unmanaged.passUnretained(self).toOpaque(), CFNotificationName(notiName as CFString), nil)
        }
    }
    
    // MARK: 移除所有的监听对象
    public func removeAllObservers() {
        for name in observerDict.keys {
            CFNotificationCenterRemoveObserver(CFNotificationCenterGetDistributedCenter(), Unmanaged.passUnretained(self).toOpaque(), CFNotificationName(name as CFString), nil)
        }
        observerDict.removeAll()
    }
    
    // MARK: - private
    
    fileprivate var observerDict: [String : [YLCFNotificationObserver]] = [:]
    private let isSandbox: Bool = ProcessInfo.processInfo.environment["APP_SANDBOX_CONTAINER_ID"] != nil
    
    private func _addObserver(_ observer: AnyObject, name: Notification.Name, selector: Selector? = nil, handler: (([String : Any]?) -> Void)? = nil, response: (([String : Any]?, ([String : Any]?) -> Void) -> Void)? = nil) {
        guard !name.rawValue.isEmpty else { return }
        let key = name.rawValue
        guard var arr = observerDict[key] else {
            // 未注册
            CFNotificationCenterAddObserver(CFNotificationCenterGetDistributedCenter(), Unmanaged.passUnretained(self).toOpaque(), YLCFNotificationCallback, key as CFString, nil, .deliverImmediately)
            let obj = YLCFNotificationObserver()
            obj.observer = observer
            obj.selector = selector
            obj.receiveHandler = handler
            obj.callbackHandler = response
            observerDict[key] = [obj]
            return
        }
        guard let object = arr.first(where: { $0.observer != nil && $0.observer === observer }) else {
            // 不存在
            let obj = YLCFNotificationObserver()
            obj.observer = observer
            obj.selector = selector
            obj.receiveHandler = handler
            obj.callbackHandler = response
            arr.append(obj)
            observerDict[key] = arr
            return
        }
        // 存在，更新
        object.selector = selector
        object.receiveHandler = handler
        object.callbackHandler = response
    }
}

fileprivate let YLCFNotificationCallbackNameSuffix = "__YL__callback"

// MARK: 通知回调
fileprivate func YLCFNotificationCallback(center: CFNotificationCenter?, observer: UnsafeMutableRawPointer?, name: CFNotificationName?, object: UnsafeRawPointer?, userInfo: CFDictionary?) {
    guard let name = name?.rawValue as String?,
          let arr = YLCFNotificationCenter.shared.observerDict[name] else { return }
    let dict = userInfo as? [String : Any]
    for obj in arr where obj.observer != nil {
        DispatchQueue.main.async {
            if let selector = obj.selector {
                _ = obj.observer?.perform(selector, with: dict)
            } else if let receiveHandler = obj.receiveHandler {
                receiveHandler(dict)
            } else if let callbackHandler = obj.callbackHandler {
                callbackHandler(dict) { responseInfo in
                    YLCFNotificationCenter.shared.postCFNotification(Notification.Name(rawValue: name + YLCFNotificationCallbackNameSuffix), userInfo: responseInfo)
                }
            }
        }
    }
}

fileprivate class YLCFNotificationObserver {
    var observer: AnyObject?
    var selector: Selector?
    var receiveHandler: (([String : Any]?) -> Void)?
    var callbackHandler: (([String : Any]?, ([String : Any]?) -> Void) -> Void)?
}
