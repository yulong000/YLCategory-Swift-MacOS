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
        if currentElement == "Name" { update?.Name = string }
        if currentElement == "BundleId" { update?.BundleId = string }
        if currentElement == "MiniVersion" { update?.MiniVersion = string }
        if currentElement == "ForceUpdateToTheLastest" { update?.ForceUpdateToTheLastest = Bool(string) ?? false }
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
    /// 有新版本，就强制升级
    var ForceUpdateToTheLastest: Bool = false
}
