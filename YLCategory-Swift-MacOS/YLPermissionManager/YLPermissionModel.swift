//
//  YLPermissionModel.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2024/12/29.
//

import Foundation

public class YLPermissionModel {
    public var authType: YLPermissionAuthType = .none
    public var desc: String = ""
    
    convenience init(authType: YLPermissionAuthType, desc: String) {
        self.init()
        self.authType = authType
        self.desc = desc
    }
    
}
