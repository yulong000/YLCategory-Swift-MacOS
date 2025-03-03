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
    
    /// AES加密
    @available(macOS 10.15, *)
    func aesEncrypt(_ key: SymmetricKey) -> Data? {
        guard let data = self.data(using: .utf8) else { return nil }
        let sealedBox = try? AES.GCM.seal(data, using: key)
        return sealedBox?.combined
    }
    
    /// AES解密
    @available(macOS 10.15, *)
    static func aesDecrypt(_ encrytpData: Data, _ key: SymmetricKey) -> String? {
        guard let sealedBox = try? AES.GCM.SealedBox(combined: encrytpData),
              let decryptedData = try? AES.GCM.open(sealedBox, using: key) else { return nil }
        return String(data: decryptedData, encoding: .utf8)
    }
    
    /// aes加密 (10.14及以下)
    func aesCBCEncrypt(key: Data, iv: Data) -> Data? {
        guard let data = self.data(using: .utf8) else { return nil }
        let bufferSize = data.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)

        var numBytesEncrypted: size_t = 0
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferBytes in
            data.withUnsafeBytes { dataBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(CCOperation(kCCEncrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress, key.count,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress, data.count,
                                bufferBytes.baseAddress, bufferSize,
                                &numBytesEncrypted)
                    }
                }
            }
        }
        
        if cryptStatus == kCCSuccess {
            return buffer.prefix(numBytesEncrypted)  // 截取有效加密数据
        }
        return nil
    }
    
    /// aes解密 (10.14及以下)
    static func aesCBCDecrypt(encryptedData: Data, key: Data, iv: Data) -> String? {
        let bufferSize = encryptedData.count + kCCBlockSizeAES128
        var buffer = Data(count: bufferSize)
        
        var numBytesDecrypted: size_t = 0
        let cryptStatus = buffer.withUnsafeMutableBytes { bufferBytes in
            encryptedData.withUnsafeBytes { encryptedBytes in
                key.withUnsafeBytes { keyBytes in
                    iv.withUnsafeBytes { ivBytes in
                        CCCrypt(CCOperation(kCCDecrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                CCOptions(kCCOptionPKCS7Padding),
                                keyBytes.baseAddress, key.count,
                                ivBytes.baseAddress,
                                encryptedBytes.baseAddress, encryptedData.count,
                                bufferBytes.baseAddress, bufferSize,
                                &numBytesDecrypted)
                    }
                }
            }
        }
        
        if cryptStatus == kCCSuccess {
            return String(data: buffer.prefix(numBytesDecrypted), encoding: .utf8)
        }
        return nil
    }
}
