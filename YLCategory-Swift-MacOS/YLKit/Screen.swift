//
//  Screen.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit

/// 屏幕的像素密度倍率
public var kScreenScale: CGFloat { NSScreen.main?.backingScaleFactor ?? 0.0 }
/// 屏幕宽度
public var kScreenWidth: CGFloat { NSScreen.main?.frame.size.width ?? 0.0 }
/// 屏幕高度
public var kScreenHeight: CGFloat { NSScreen.main?.frame.size.height ?? 0.0 }
/// 状态栏高度
public var kStatusBarHeight: CGFloat { NSApp.mainMenu?.menuBarHeight ?? 0.0 }
