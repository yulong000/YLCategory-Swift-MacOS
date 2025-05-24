//
//  YLUpdateXMLParserDelegate.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/30.
//

import Foundation

class YLUpdateXMLParserDelegate: NSObject, XMLParserDelegate {
    
    var update: YLUpdateXMLModel? = YLUpdateXMLModel()
    var currentElement: String? = ""
    
    // MARK: 解析开始某个元素
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentElement = elementName
    }
    
    // MARK: 读取元素内容
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        guard let currentElement = currentElement else { return }
        switch currentElement {
        case "Name":                    update?.Name = string
        case "BundleId":                update?.BundleId = string
        case "ForceUpdateToTheLatest":  update?.ForceUpdateToTheLatest = Bool(string) ?? Bool(Int(string) == 0 ? "false" : "true")
        case "MiniVersion":             update?.MiniVersion = string
        case "ExpiredDate":             update?.ExpiredDate = string
        case "ExpiredOSVersion":        update?.ExpiredOSVersion = string
        default: break
        }
    }
    
    // MARK: 结束某个元素的解析
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        currentElement = nil
    }
    
    // MARK: 解析完成
    func parserDidEndDocument(_ parser: XMLParser) { }
    
    // MARK: 解析失败
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: any Error) {
        update = nil
    }
}


struct YLUpdateXMLModel {
    /// app名字
    var Name: String?
    /// app的bundle ID
    var BundleId: String?
    /// 支持最小版本号，小于该版本号的，强制升级
    var MiniVersion: String?
    /// 失效的系统版本号
    var ExpiredOSVersion: String?
    /// 失效的日期, 格式： yyyy-MM-dd
    var ExpiredDate: String?
    /// 有新版本，就强制升级
    var ForceUpdateToTheLatest: Bool?
    
    func toJson() -> [String: Any] {
        return [
            "Name": Name ?? "",
            "BundleId": BundleId ?? "",
            "MiniVersion": MiniVersion ?? "",
            "ExpiredOSVersion": ExpiredOSVersion ?? "",
            "ExpiredDate": ExpiredDate ?? "",
            "ForceUpdateToTheLatest": ForceUpdateToTheLatest ?? false
        ]
    }
}
