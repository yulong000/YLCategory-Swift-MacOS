//
//  NSObject+Notification.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/25.
//

import Foundation

public extension NSObject {
    
    // MARK: - 普通通知
    
    // MARK: 发送通知
    func postNotification(name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
        NotificationCenter.default.post(name: name, object: self, userInfo: userInfo)
    }
    
    // MARK: 接收通知
    func addNotification(name: Notification.Name, handler: @escaping @Sendable (Notification) -> Void) {
        NotificationCenter.default.addObserver(forName: name, object: nil, queue: .main, using: handler)
    }
    
    // MARK: 移除通知
    func removeNotification(name: Notification.Name) {
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
    }
    
    // MARK: 移除所有通知
    func removeAllNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - 分布式通知
    
    // MARK: 发送通知
    func postDistributedNotification(name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
        DistributedNotificationCenter.default().post(name: name, object: nil, userInfo: userInfo)
    }
    
    // MARK: 接收通知
    func addDistributedNotification(name: Notification.Name, handler: @escaping @Sendable (Notification) -> Void) {
        DistributedNotificationCenter.default().addObserver(forName: name, object: nil, queue: .main, using: handler)
    }
    
    // MARK: 移除通知
    func removeDistributedNotification(name: Notification.Name) {
        DistributedNotificationCenter.default().removeObserver(self, name: name, object: nil)
    }
    
    // MARK: 移除所有通知
    func removeAllDistributedNotifications() {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    // MARK: - 系统通知
    
    // MARK: 发送通知
    func postWorkspaceNotification(name: Notification.Name, userInfo: [AnyHashable : Any]? = nil) {
        NSWorkspace.shared.notificationCenter.post(name: name, object: self, userInfo: userInfo)
    }
    
    // MARK: 接收通知
    func addWorkspaceNotification(name: Notification.Name, handler: @escaping @Sendable (Notification) -> Void) {
        NSWorkspace.shared.notificationCenter.addObserver(forName: name, object: nil, queue: .main, using: handler)
    }
    
    // MARK: 移除通知
    func removeWorkspaceNotification(name: Notification.Name) {
        NSWorkspace.shared.notificationCenter.removeObserver(self, name: name, object: nil)
    }
    
    // MARK: 移除所有通知
    func removeAllWorkspaceNotifications() {
        NSWorkspace.shared.notificationCenter.removeObserver(self)
    }
}
