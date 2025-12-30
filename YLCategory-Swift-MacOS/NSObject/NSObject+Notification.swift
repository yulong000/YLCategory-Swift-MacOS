//
//  NSObject+Notification.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/25.
//

import Foundation
import AppKit

fileprivate var NotificationDictKey = false
fileprivate var DistributedNotificationDictKey = false
fileprivate var WorkspaceNotificationDictKey = false

public extension NSObject {
    
    // MARK: - 普通通知
    
    // MARK: 发送通知
    func postNotification(name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: name, object: object ?? self, userInfo: userInfo)
    }
    
    // MARK: 接收通知
    func addNotification(name: Notification.Name, object: Any? = nil, handler: @escaping (Notification) -> Void) {
        NotificationCenter.default.addObserver(self, selector: #selector(received(_:)), name: name, object: object)
        if NotificationDict == nil {
            NotificationDict = [:]
        }
        NotificationDict?[name] = handler
    }
    
    // MARK: 移除通知
    func removeNotification(name: Notification.Name) {
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
        NotificationDict?.removeValue(forKey: name)
    }
    
    // MARK: 移除所有通知
    func removeAllNotifications() {
        NotificationCenter.default.removeObserver(self)
        NotificationDict?.removeAll()
    }
    
    // MARK: 收到通知消息
    @objc private func received(_ notification: Notification) {
        guard let handler = NotificationDict?[notification.name] as? (Notification) -> Void else { return }
        handler(notification)
    }
    
    // MARK: 存储事件监听器
    private var NotificationDict: [Notification.Name: Any]? {
        get { objc_getAssociatedObject(self, &NotificationDictKey) as? [Notification.Name: Any] }
        set { objc_setAssociatedObject(self, &NotificationDictKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - 分布式通知
    
    // MARK: 发送通知
    func postDistributedNotification(name: Notification.Name, object: String? = nil, userInfo: [AnyHashable : Any]? = nil) {
        DistributedNotificationCenter.default().postNotificationName(name, object: object, userInfo: userInfo, deliverImmediately: true)
    }
    
    // MARK: 接收通知
    func addDistributedNotification(name: Notification.Name, object: String? = nil, handler: @escaping (Notification) -> Void) {
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(receivedDistributed(_:)), name: name, object: object, suspensionBehavior: .deliverImmediately)
        if DistributedNotificationDict == nil {
            DistributedNotificationDict = [:]
        }
        DistributedNotificationDict?[name] = handler
    }
    
    // MARK: 移除通知
    func removeDistributedNotification(name: Notification.Name) {
        DistributedNotificationCenter.default().removeObserver(self, name: name, object: nil)
        DistributedNotificationDict?.removeValue(forKey: name)
    }
    
    // MARK: 移除所有通知
    func removeAllDistributedNotifications() {
        DistributedNotificationCenter.default().removeObserver(self)
        DistributedNotificationDict?.removeAll()
    }
    
    // MARK: 收到通知消息
    @objc private func receivedDistributed(_ notification: Notification) {
        guard let handler = DistributedNotificationDict?[notification.name] as? (Notification) -> Void else { return }
        handler(notification)
    }
    
    // MARK: 存储事件监听器
    private var DistributedNotificationDict: [Notification.Name: Any]? {
        get { objc_getAssociatedObject(self, &DistributedNotificationDictKey) as? [Notification.Name: Any] }
        set { objc_setAssociatedObject(self, &DistributedNotificationDictKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
    
    // MARK: - 系统通知
    
    // MARK: 发送通知
    func postWorkspaceNotification(name: Notification.Name, object: Any? = nil, userInfo: [AnyHashable : Any]? = nil) {
        NSWorkspace.shared.notificationCenter.post(name: name, object: object, userInfo: userInfo)
    }
    
    // MARK: 接收通知
    func addWorkspaceNotification(name: Notification.Name, object: Any? = nil, handler: @escaping (Notification) -> Void) {
        NSWorkspace.shared.notificationCenter.addObserver(self, selector: #selector(receivedWorkspace(_:)), name: name, object: object)
        if WorkspaceNotificationDict == nil {
            WorkspaceNotificationDict = [:]
        }
        WorkspaceNotificationDict?[name] = handler
    }
    
    // MARK: 移除通知
    func removeWorkspaceNotification(name: Notification.Name) {
        NSWorkspace.shared.notificationCenter.removeObserver(self, name: name, object: nil)
        WorkspaceNotificationDict?.removeValue(forKey: name)
    }
    
    // MARK: 移除所有通知
    func removeAllWorkspaceNotifications() {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
        WorkspaceNotificationDict?.removeAll()
    }
    
    // MARK: 收到通知消息
    @objc private func receivedWorkspace(_ notification: Notification) {
        guard let handler = WorkspaceNotificationDict?[notification.name] as? (Notification) -> Void else { return }
        handler(notification)
    }
    
    // MARK: 存储事件监听器
    private var WorkspaceNotificationDict: [Notification.Name: Any]? {
        get { objc_getAssociatedObject(self, &WorkspaceNotificationDictKey) as? [Notification.Name: Any] }
        set { objc_setAssociatedObject(self, &WorkspaceNotificationDictKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC) }
    }
}
