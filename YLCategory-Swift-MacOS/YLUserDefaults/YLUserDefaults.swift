//
//  YLUserDefaults.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/26.
//

import Foundation

public class YLUserDefaults {
    
    static let shared = YLUserDefaults()
    private init() {}
    
    // MARK: - app
    
    var userDefaults: UserDefaults { get { UserDefaults.standard } }
    
    func setObject(_ obj: Any?, forKey key: String) {
        userDefaults.set(obj, forKey: key)
        userDefaults.synchronize()
    }
    func object(forKey key: String) -> Any? { userDefaults.object(forKey: key) }
    func removeObject(forKey key: String) {
        userDefaults.removeObject(forKey: key)
        userDefaults.synchronize()
    }
    
    func string(forKey key: String) -> String? { userDefaults.string(forKey: key) }
    func array(forKey key: String) -> [Any]? { userDefaults.array(forKey: key) }
    func dictionary(forKey key: String) -> [String: Any]? { userDefaults.dictionary(forKey: key) }
    func data(forKey key: String) -> Data? { userDefaults.data(forKey: key) }

    func setInteger(_ value: Int, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    func integer(forKey key: String) -> Int { userDefaults.integer(forKey: key) }
    
    func setFloat(_ value: Float, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    func float(forKey key: String) -> Float { userDefaults.float(forKey: key) }
    
    func setDouble(_ value: Double, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    func double(forKey key: String) -> Double { userDefaults.double(forKey: key) }
    
    func setBool(_ value: Bool, forKey key: String) {
        userDefaults.set(value, forKey: key)
        userDefaults.synchronize()
    }
    func bool(forKey key: String) -> Bool { userDefaults.bool(forKey: key) }
    
    func setURL(_ url: URL?, forKey key: String) {
        userDefaults.set(url, forKey: key)
        userDefaults.synchronize()
    }
    func url(forKey key: String) -> URL? { userDefaults.url(forKey: key) }
    
    func setObjectsWithKeys(_ keyValues: [String: Any]) {
        for (key, value) in keyValues {
            userDefaults.set(value, forKey: key)
        }
        userDefaults.synchronize()
    }
    
    
    // MARK: - group
    
    private(set) var groupDefaults: UserDefaults?
    private var groupDefaultsDict: [String : UserDefaults] = [:]
    
    func setGroupName(_ name: String) {
        guard !name.isEmpty else { return }
        groupDefaults = UserDefaults(suiteName: name)
        groupDefaultsDict[name] = groupDefaults
    }
    
    func setObject(_ obj: Any?, forGroupKey key: String) {
        groupDefaults?.set(obj, forKey: key)
        groupDefaults?.synchronize()
    }
    func object(forGroupKey key: String) -> Any? { groupDefaults?.object(forKey: key) }
    func removeObject(forGroupKey key: String) {
        groupDefaults?.removeObject(forKey: key)
        groupDefaults?.synchronize()
    }
    
    func string(forGroupKey key: String) -> String? { groupDefaults?.string(forKey: key) }
    func array(forGroupKey key: String) -> [Any]? { groupDefaults?.array(forKey: key) }
    func dictionary(forGroupKey key: String) -> [String: Any]? { groupDefaults?.dictionary(forKey: key) }
    func data(forGroupKey key: String) -> Data? { groupDefaults?.data(forKey: key) }
    
    func setInteger(_ value: Int, forGroupKey key: String) {
        groupDefaults?.set(value, forKey: key)
        groupDefaults?.synchronize()
    }
    func integer(forGroupKey key: String) -> Int { groupDefaults?.integer(forKey: key) ?? 0 }
    
    func setFloat(_ value: Float, forGroupKey key: String) {
        groupDefaults?.set(value, forKey: key)
        groupDefaults?.synchronize()
    }
    func float(forGroupKey key: String) -> Float { groupDefaults?.float(forKey: key) ?? 0.0 }
    
    func setDouble(_ value: Double, forGroupKey key: String) {
        groupDefaults?.set(value, forKey: key)
        groupDefaults?.synchronize()
    }
    func double(forGroupKey key: String) -> Double { groupDefaults?.double(forKey: key) ?? 0.0 }
    
    func setBool(_ value: Bool, forGroupKey key: String) {
        groupDefaults?.set(value, forKey: key)
        groupDefaults?.synchronize()
    }
    func bool(forGroupKey key: String) -> Bool { groupDefaults?.bool(forKey: key) ?? false }
    
    func setURL(_ url: URL?, forGroupKey key: String) {
        groupDefaults?.set(url, forKey: key)
        groupDefaults?.synchronize()
    }
    func url(forGroupKey key: String) -> URL? { groupDefaults?.url(forKey: key) }
    
    func setObjectsWithGroupKeys(_ keyValues: [String: Any]) {
        for (key, value) in keyValues {
            groupDefaults?.set(value, forKey: key)
        }
        groupDefaults?.synchronize()
    }
    
    // MARK: - groups
    
    @discardableResult
    func addGroup(withName name: String) -> UserDefaults? {
        guard !name.isEmpty else { return nil }
        if let defaults = groupDefaultsDict[name] {
            return defaults
        }
        let group = UserDefaults(suiteName: name)
        groupDefaultsDict[name] = group
        return group
    }
    
    func removeGroup(withName name: String) {
        guard let group = groupDefaultsDict[name] else { return }
        groupDefaultsDict.removeValue(forKey: name)
        if group === groupDefaults {
            groupDefaults = nil
        }
    }
    
    func groupDefaults(withName name: String) -> UserDefaults? { groupDefaultsDict[name] }
    
    func setObject(_ obj: Any?, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(obj, forKey: key)
        defaults.synchronize()
    }
    func object(forGroup name: String, key: String) -> Any? {
        return groupDefaults(withName: name)?.object(forKey: key)
    }
    func removeObject(forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.removeObject(forKey: key)
        defaults.synchronize()
    }
    
    func string(forGroup name: String, key: String) -> String? {
        guard let defaults = groupDefaults(withName: name) else { return nil }
        return defaults.string(forKey: key)
    }
    func array(forGroup name: String, key: String) -> [Any]? {
        guard let defaults = groupDefaults(withName: name) else { return nil }
        return defaults.array(forKey: key)
    }
    func dictionary(forGroup name: String, key: String) -> [String: Any]? {
        guard let defaults = groupDefaults(withName: name) else { return nil }
        return defaults.dictionary(forKey: key)
    }
    func data(forGroup name: String, key: String) -> Data? {
        guard let defaults = groupDefaults(withName: name) else { return nil }
        return defaults.data(forKey: key)
    }
    
    func setInteger(_ value: Int, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    func integer(forGroup name: String, key: String) -> Int {
        guard let defaults = groupDefaults(withName: name) else { return 0 }
        return defaults.integer(forKey: key)
    }
    
    func setFloat(_ value: Float, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    func float(forGroup name: String, key: String) -> Float {
        guard let defaults = groupDefaults(withName: name) else { return 0.0 }
        return defaults.float(forKey: key)
    }
    
    func setDouble(_ value: Double, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    func double(forGroup name: String, key: String) -> Double {
        guard let defaults = groupDefaults(withName: name) else { return 0.0 }
        return defaults.double(forKey: key)
    }
    
    func setBool(_ value: Bool, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(value, forKey: key)
        defaults.synchronize()
    }
    func bool(forGroup name: String, key: String) -> Bool {
        guard let defaults = groupDefaults(withName: name) else { return false }
        return defaults.bool(forKey: key)
    }
    
    func setURL(_ url: URL?, forGroup name: String, key: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        defaults.set(url, forKey: key)
        defaults.synchronize()
    }
    func url(forGroup name: String, key: String) -> URL? {
        guard let defaults = groupDefaults(withName: name) else { return nil }
        return defaults.url(forKey: key) }
    
    func setObjectsWithKeys(_ keyValues: [String: Any], forGroup name: String) {
        guard let defaults = groupDefaults(withName: name) else { return }
        for (key, value) in keyValues {
            defaults.set(value, forKey: key)
        }
        defaults.synchronize()
    }
}
