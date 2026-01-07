//
//  Extension.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2026/1/7.
//

public extension Dictionary where Key == String, Value == Any {
    
    /// 从[String:Any]中读取bool值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func bool(_ key: String, default value: Bool = false) -> Bool {
        if let v = self[key] as? Bool { return v }
        if let v = self[key] as? Int { return v != 0 }
        if let v = self[key] as? String {
            return v == "1" || v.lowercased() == "true" || v.lowercased() == "yes"
        }
        return value
    }
    
    /// 从[String:Any]中读取String，value为空时，返回nil
    /// - Parameters:
    ///   - key: key值
    /// - Returns: 返回值
    func string(_ key: String) -> String? {
        if let v = self[key] as? String { return v }
        if let v = self[key] as? Int { return String(v) }
        if let v = self[key] as? Double { return String(v) }
        if let v = self[key] as? Bool { return v ? "true" : "false" }
        return nil
    }
    
    
    /// 从[String:Any]中读取String，value为空时，返回“”
    /// - Parameter key: key值
    /// - Returns: 返回值
    func stringValue(_ key: String) -> String { string(key) ?? "" }
    
    /// 从[String:Any]中读取Int值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func int(_ key: String, default value: Int = 0) -> Int {
        if let v = self[key] as? Int { return v }
        if let v = self[key] as? String { return Int(v) ?? value }
        if let v = self[key] as? Double { return Int(v) }
        if let v = self[key] as? Bool { return v ? 1 : 0 }
        return value
    }
    
    /// 从[String:Any]中读取Double值
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func double(_ key: String, default value: Double = 0) -> Double {
        if let v = self[key] as? Double { return v }
        if let v = self[key] as? Int { return Double(v) }
        if let v = self[key] as? String { return Double(v) ?? value }
        return value
    }
    
    /// 从[String:Any]中读取Dictionary
    /// - Parameters:
    ///   - key: key值
    ///   - value: 解析失败返回的值
    /// - Returns: 返回值
    func dict(_ key: String) -> [String: Any]? {
        return self[key] as? [String: Any]
    }
    
    /// 从[String:Any]中读取Array
    /// - Parameters:
    ///   - key: key值
    ///   - T: 数组内的类型，必须是可通过 as? 从 JSON 数组中转换的类型
    /// - Returns: 返回值
    func array<T>(_ key: String, _: T.Type) -> [T] {
        return self[key] as? [T] ?? []
    }
    
    /// 从[String:Any]中读取Array并 1: 1转换成模型数组
    /// - Parameters:
    ///   - key: key值
    ///   - _: 需要转换的模型
    /// - Returns: 返回值
    func models<T: JsonInitializable>(_ key: String, _: T.Type) -> [T] {
        let arr = self.array(key, [String: Any].self)
        return arr.models(T.self)
    }
    
    /// 从[String:Any]中读取Array并转换成模型数组，会过滤掉无效的数据
    /// - Parameters:
    ///   - key: key值
    ///   - _: 需要转换的模型
    /// - Returns: 返回值
    func strictModels<T: JsonInitializableNullable>(_ key: String, _: T.Type) -> [T] {
        let arr = self.array(key, [String: Any].self)
        return arr.strictModels(T.self)
    }
}

public extension Array where Element == [String: Any] {
    
    /// 1: 1转换成模型数组
    /// - Parameters:
    ///   - key: key值
    ///   - T: 需要转换的模型
    /// - Returns: 返回值
    func models<T: JsonInitializable>(_: T.Type) -> [T] {
        return map { T(json: $0) }
    }
    
    /// 转换成模型数组，会过滤掉无效的数据
    /// - Parameters:
    ///   - T: 需要转换的模型
    /// - Returns: 返回值
    func strictModels<T: JsonInitializableNullable>(_: T.Type) -> [T] {
        return compactMap { T(strictJson: $0) }
    }
}

/// 字典转模型的协议， 肯定会成功
public protocol JsonInitializable {
    init(json: [String: Any])
}

/// 字典转模型的协议, 允许失败
public protocol JsonInitializableNullable {
    init?(strictJson: [String: Any])
}
