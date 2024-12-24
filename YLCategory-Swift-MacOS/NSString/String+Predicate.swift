//
//  String+Predicate.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/24.
//

import Foundation

public extension String {
    
    /// 匹配正则表达式
    /// - Parameter regex: 正则
    /// - Returns: 返回是否匹配
    func isValid(by regex: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", regex)
        return predicate.evaluate(with: self)
    }
    
    /// 是否是中国手机号
    func isChineseMobileNumer() -> Bool { isValid(by: "^(1[3-9][0-9])\\d{8}$")  }
    
    /// 是否是有效的邮箱地址
    func isEmailAddress() -> Bool { isValid(by: "[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}") }
    
    /// 身份证号校验
    func isIDCard() -> Bool {
        // 先进行模糊匹配
        guard isValid(by: "^\\d{17}(\\d|[xX])$") else { return false }
        // 匹配省份
        let province = String(prefix(2))
        let provinceArray = ["11", "12", "13", "14", "15", "21", "22", "23", "31", "32",
                             "33", "34", "35", "36", "37", "41", "42", "43", "44", "45",
                             "46", "50", "51", "52", "53", "54", "61", "62", "63", "64",
                             "65", "71", "81", "82", "91"]
        guard provinceArray.contains(province) else { return false }
        
        // 匹配年份
        let yearString = (self as NSString).substring(with: NSRange(location: 6, length: 4))
        guard yearString.isValid(by: "^(18|19|20)[0-9]{2}$") else { return false }
        
        // 匹配日月
        let dayString = (self as NSString).substring(with: NSRange(location: 10, length: 4))
        if dayString.prefix(2) == "02" {
            let year = Int(yearString) ?? 0
            let leapYear = (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
            let regex = leapYear ? "^02(0[1-9]|[1-2][0-9])$" : "^02(0[1-9]|1[0-9]|2[0-8])$"
            guard dayString.isValid(by: regex) else { return false }
        } else {
            let regex = "(01|03|05|07|08|10|12)(0[1-9]|[1-2][0-9]|3[0-1])|(04|06|09|11)(0[1-9]|[1-2][0-9]|30)"
            guard dayString.isValid(by: regex) else { return false }
        }
        
        // 校验位
        let last = suffix(1).uppercased()
        let weights = [7, 9, 10, 5, 8, 4, 2, 1, 6, 3, 7, 9, 10, 5, 8, 4, 2]
        let sum = zip(prefix(17), weights).reduce(0) { acc, pair in
            acc + (Int(String(pair.0)) ?? 0) * pair.1
        }
        let checkCodes = "10X98765432"
        let checkChar = checkCodes[checkCodes.index(checkCodes.startIndex, offsetBy: sum % 11)]
        return last == String(checkChar)
    }
    
    /// 车牌号校验
    func isCarNumber() -> Bool { isValid(by: "^[\u{4e00}-\u{9fff}]{1}[a-zA-Z]{1}-[a-zA-Z0-9]{4}[a-zA-Z0-9\u{4e00}-\u{9fff}]$") }
    
    /// 银行卡号校验
    func isBankCardNumber() -> Bool {
        let reversedDigits = dropLast().reversed().compactMap { Int(String($0)) }
        let checkDigit = Int(suffix(1)) ?? 0
        let sum = reversedDigits.enumerated().reduce(0) { acc, pair in
            let (index, digit) = pair
            if index % 2 == 0 {
                let doubled = digit * 2
                return acc + (doubled > 9 ? doubled - 9 : doubled)
            } else {
                return acc + digit
            }
        }
        return (sum + checkDigit) % 10 == 0
    }
    
    /// 纯数字
    func isNumberText() -> Bool { isValid(by: "[0-9]*") }
    
    /// 只包含数字+字母
    func isNumberOrChar() -> Bool { isValid(by: "^[A-Za-z0-9]+$") }
    
    
}
