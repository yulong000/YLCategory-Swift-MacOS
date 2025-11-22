//
//  Font.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit

/// 默认字号
public func Font(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size) }
/// 粗体
public func BoldFont(_ size: CGFloat) -> NSFont { .boldSystemFont(ofSize: size) }
/// 中粗
public func MediumFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .medium) }
/// 细粗
public func ThinFont(_ size: CGFloat) -> NSFont { .systemFont(ofSize: size, weight: .thin) }
