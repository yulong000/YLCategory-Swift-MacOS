//
//  String+Secret.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/24.
//

import Foundation
import CommonCrypto
import CryptoKit

public extension String {
    
    /// MD5 小写 加密
    var md5Lower: String {
        guard let data = data(using: .utf8) else { return ""}
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02x", $0) }.joined()
    }
    
    /// MD5 大写 加密
    var md5Upper: String {
        guard let data = data(using: .utf8) else { return ""}
        var digest = [UInt8](repeating: 0, count: Int(CC_MD5_DIGEST_LENGTH))
        data.withUnsafeBytes { bytes in
            _ = CC_MD5(bytes.baseAddress, CC_LONG(data.count), &digest)
        }
        return digest.map { String(format: "%02X", $0) }.joined()
    }
    
    /// base 64 编码
    var base64Encode: String {
        guard let data = data(using: .utf8) else { return ""}
        return data.base64EncodedString()
    }
    
    /// base 64 解码
    var base64Decode: String {
        guard let data = Data(base64Encoded: self as String) else { return "" }
        return String(data: data, encoding: .utf8) ?? ""
    }
    
    /// SHA-256 字符串
    var sha256: String {
        if #available(macOS 10.15, *) {
            let data = Data(self.utf8)
            let hash = SHA256.hash(data: data)
            return hash.map { String(format: "%02x", $0)}.joined()
        }
        return ""
    }
}
