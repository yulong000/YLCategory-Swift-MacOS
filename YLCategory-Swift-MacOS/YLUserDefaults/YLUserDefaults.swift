//
//  YLUserDefaults.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation

public class YLUserDefaults {
    
    public static let shared = YLUserDefaults()
    private init() {}
    
    // MARK: - app
    
    public var userDefaults: UserDefaults { get { UserDefaults.standard } }
    
    public func setObject(_ obj: Any?, forKey key: String) {
        userDefaults.set(obj, forKey: key)
        userDefaults.synchronize()
    }
    public func object(forKey key: String) -> Any? { userDefaults.object(forKey: key) }
    public func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }
    
    public func string(forKey key: String) -> String? { userDefaults.string(forKey: key) }
    public func array(forKey key: String) -> [Any]? { userDefaults.array(forKey: key) }
    public func dictionary(forKey key: String) -> [String: Any]? { userDefaults.dictionary(forKey: key) }
    public func data(forKey key: String) -> Data? { userDefaults.data(forKey: key) }

    public func setInteger(_ value: Int, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    public func integer(forKey key: String) -> Int { userDefaults.integer(forKey: key) }
    
    public func setFloat(_ value: Float, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    public func float(forKey key: String) -> Float { userDefaults.float(forKey: key) }
    
    public func setDouble(_ value: Double, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    public func double(forKey key: String) -> Double { userDefaults.double(forKey: key) }
    
    public func setBool(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    public func bool(forKey key: String) -> Bool { userDefaults.bool(forKey: key) }
    
    public func setURL(_ url: URL?, forKey key: String) {
        userDefaults.set(url, forKey: key)
        userDefaults.synchronize()
    }
    public func url(forKey key: String) -> URL? { userDefaults.url(forKey: key) }
    
    public func setObjectsWithKeys(_ keyValues: [String: Any]) {
        for (key, value) in keyValues {
            userDefaults.set(value, forKey: key)
        }
        userDefaults.synchronize()
    }
    
    
    // MARK: - group
    
    public private(set) var groupDefaults: UserDefaults?
    private var groupDefaultsDict: [String : UserDefaults] = [:]
    
    public func setGroupName(_ name: String) {
        guard !name.isEmpty else { return }
        groupDefaults = UserDefaults(suiteName: name)
        groupDefaultsDict[name] = groupDefaults
    }
    
    public func setObject(_ obj: Any?, forGroupKey key: String) {
        groupDefaults?.set(obj, forKey: key)
        groupDefaults?.synchronize()
    }
    public func object(forGroupKey key: String) -> Any? { groupDefaults?.object(forKey: key) }
    public func removeObject(forGroupKey key: String) {
        groupDefaults?.removeObject(forKey: key)
        groupDefaults?.synchronize()
    }
    
    public func string(forGroupKey key: String) -> String? { groupDefaults?.string(forKey: key) }
    public func array(forGroupKey key: String) -> [Any]? { groupDefaults?.array(forKey: key) }
    public func dictionary(forGroupKey key: String) -> [String: Any]? { groupDefaults?.dictionary(forKey: key) }
    public func data(forGroupKey key: String) -> Data? { groupDefaults?.data(forKey: key) }
    
    public func setInteger(_ value: Int, forGroupKey key: String) {
        groupDefaults?.set(value, forKey: key)
        groupDefaults?.synchronize()
    }
    public func integer(forGroupKey key: String) -> Int { groupDefaults?.integer(forKey: key) ?? 0 }
    
    public func setFloat(_ value: Float, forGroupKey key: String) {
        groupDefaults?.set(value, forKey: key)
        groupDefaults?.synchronize()
    }
    public func float(forGroupKey key: String) -> Float { groupDefaults?.float(forKey: key) ?? 0.0 }
    
    public func setDouble(_ value: Double, forGroupKey key: String) {
        groupDefaults?.set(value, forKey: key)
        groupDefaults?.synchronize()
    }
    public func double(forGroupKey key: String) -> Double { groupDefaults?.double(forKey: key) ?? 0.0 }
    
    public func setBool(_ value: Bool, forGroupKey key: String) {
        groupDefaults?.set(value, forKey: key)
        groupDefaults?.synchronize()
    }
    public func bool(forGroupKey key: String) -> Bool { groupDefaults?.bool(forKey: key) ?? false }
    
    public func setURL(_ url: URL?, forGroupKey key: String) {
        groupDefaults?.set(url, forKey: key)
        groupDefaults?.synchronize()
    }
    public func url(forGroupKey key: String) -> URL? { groupDefaults?.url(forKey: key) }
    
    public func setObjectsWithGroupKeys(_ keyValues: [String: Any]) {
        for (key, value) in keyValues {
            groupDefaults?.set(value, forKey: key)
        }
        groupDefaults?.synchronize()
    }
    
    // MARK: - groups
    
    @discardableResult
    public func addGroup(withName name: String) -> UserDefaults? {
        guard !name.isEmpty else { return nil }
        if let defaults = groupDefaultsDict[name] {
            return defaults
        }
        let group = UserDefaults(suiteName: name)
        groupDefaultsDict[name] = group
        return group
    }
    
    public func removeGroup(withName name: String) {
        guard let group = groupDefaultsDict[name] else { return }
        groupDefaultsDict.removeValue(forKey: name)
        if group === groupDefaults {
            groupDefaults = nil
        }
    }
    
    public func groupDefaults(withName name: String) -> UserDefaults? { groupDefaultsDict[name] }
    
    public func setObject(_ obj: Any?, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(obj, forKey: key)
        defaults.synchronize()
    }
    public func object(forGroup name: String, key: String) -> Any? {
        return groupDefaults(withName: name)?.object(forKey: key)
    }
    public func removeObject(forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
    
    public func string(forGroup name: String, key: String) -> String? {
        guard let defaults = groupDefaults(withName: name) else { return nil }
        return defaults.string(forKey: key)
    }
    public func array(forGroup name: String, key: String) -> [Any]? {
        guard let defaults = groupDefaults(withName: name) else { return nil }
        return defaults.array(forKey: key)
    }
    public func dictionary(forGroup name: String, key: String) -> [String: Any]? {
        guard let defaults = groupDefaults(withName: name) else { return nil }
        return defaults.dictionary(forKey: key)
    }
    public func data(forGroup name: String, key: String) -> Data? {
        guard let defaults = groupDefaults(withName: name) else { return nil }
        return defaults.data(forKey: key)
    }
    
    public func setInteger(_ value: Int, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    public func integer(forGroup name: String, key: String) -> Int {
        guard let defaults = groupDefaults(withName: name) else { return 0 }
        return defaults.integer(forKey: key)
    }
    
    public func setFloat(_ value: Float, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    public func float(forGroup name: String, key: String) -> Float {
        guard let defaults = groupDefaults(withName: name) else { return 0.0 }
        return defaults.float(forKey: key)
    }
    
    public func setDouble(_ value: Double, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    public func double(forGroup name: String, key: String) -> Double {
        guard let defaults = groupDefaults(withName: name) else { return 0.0 }
        return defaults.double(forKey: key)
    }
    
    public func setBool(_ value: Bool, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    public func bool(forGroup name: String, key: String) -> Bool {
        guard let defaults = groupDefaults(withName: name) else { return false }
        return defaults.bool(forKey: key)
    }
    
    public func setURL(_ url: URL?, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(url, forKey: key)
        defaults.synchronize()
    }
    public func url(forGroup name: String, key: String) -> URL? {
        guard let defaults = groupDefaults(withName: name) else { return nil }
        return defaults.url(forKey: key) }
    
    public func setObjectsWithKeys(_ keyValues: [String: Any], forGroup name: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        for (key, value) in keyValues {
            defaults.set(value, forKey: key)
        }
        defaults.synchronize()
    }
}
