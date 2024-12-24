//
//  String+Category.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/24.
//

import Foundation

public extension String {
    
    /// 获取本地化内容
    var local: String { NSLocalizedString(self, comment: "") }
    
    /// 获取 string 的 size
    /// - Parameters:
    ///   - maxWidth: 最大宽度， 超过自动换行
    ///   - font: 字体大小
    /// - Returns: 自适应以后的大小
    func sizeWith(maxWidth: CGFloat, font: NSFont) -> NSSize {
        self.boundingRect(with: NSMakeSize(maxWidth, CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font : font], context: nil).size
    }
    
    /// 去掉首部的字符集合
    /// - Parameter characterSet: 字符集合
    /// - Returns: 处理后的字符串
    func trimmingPrefixCharacters(in characterSet: CharacterSet) -> String {
        guard let startIndex = self.unicodeScalars.firstIndex(where: { !characterSet.contains($0) }) else { return "" }
        return String(self[startIndex...])
    }
    
    /// 去掉尾部的字符集合
    /// - Parameter characterSet: 字符集合
    /// - Returns: 处理后的字符串
    func trimmingSuffixCharacters(in characterSet: CharacterSet) -> String {
        guard let endIndex = self.unicodeScalars.lastIndex(where: { !characterSet.contains($0) }) else { return "" }
        return String(self[...endIndex])
    }
    
    /// 去掉首部的空格
    func trimmingPrefixWhitespace() -> String {
        trimmingPrefixCharacters(in: .whitespaces)
    }
    
    /// 去掉尾部的空格
    func trimmingSuffixWhitespace() -> String {
        trimmingSuffixCharacters(in: .whitespaces)
    }
    
    /// 去掉尾部的空格和换行
    func trimmingSuffixWhitespaceAndNewline() -> String {
        trimmingSuffixCharacters(in: .whitespacesAndNewlines)
    }
    
    /// 正则匹配字符串
    /// - Parameters:
    ///   - regular: 规则
    ///   - options: 选项
    ///   .caseInsensitive   忽略大小写 "AA"相当于"aa"
    ///   .allowCommentsAndWhitespace   忽略空格和#后面的注释 "A B#AA"相当于"AB"
    ///   .ignoreMetacharacters   将整个模式视为文字字符串 "AA\\b"其中的\\b不会当成匹配边界，而是字符串
    ///   .dotMatchesLineSeparators   允许.匹配任何字符，包括行分隔符。"a.b"可以匹配"a\nb"
    ///   .anchorsMatchLines   允许^和$匹配行的开头和结尾(这个好像是一直生效的)
    ///   .useUnixLineSeparators   仅将\n视为行分隔符，否则，将使用所有标准行分隔符
    ///   .useUnicodeWordBoundaries   使用Unicode TR#29指定单词边界，否则，使用传统的正则表达式单词边界
    /// - Returns: 返回匹配到的范围
    func match(with regular: String, options: NSRegularExpression.Options = []) -> [NSRange] {
        guard let regex = try? NSRegularExpression(pattern: regular, options: options) else { return [] }
        let matches = regex.matches(in: self, options: [], range: NSRange(location: 0, length: (self as NSString).length))
        return matches.flatMap { match in
            (0..<match.numberOfRanges).map { match.range(at: $0) }
        }
    }
    
    /// 获取传入字符串的范围
    /// - Parameter string: 传入的字符串
    /// - Returns: 返回所有匹配的范围
    func rangesOf(_ string: String) -> [NSRange] {
        match(with: NSRegularExpression.escapedPattern(for: string), options: .ignoreMetacharacters)
    }
}
