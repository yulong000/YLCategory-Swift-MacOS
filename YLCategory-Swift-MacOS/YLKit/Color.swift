//
//  Color.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/11/22.
//


import AppKit

public let WhiteColor: NSColor = .white
public let BlackColor: NSColor = .black
public let ClearColor: NSColor = .clear
public let GrayColor: NSColor = .gray
public let DarkGrayColor: NSColor = .darkGray
public let LightGrayColor: NSColor = .lightGray
public let RedColor: NSColor = .red
public let GreenColor: NSColor = .green
public let OrangeColor: NSColor = .orange
public let YellowColor: NSColor = .yellow
public let BlueColor: NSColor = .blue
public let SystemBlueColor: NSColor = .systemBlue
public let ControlAccentColor: NSColor = .controlAccentColor

public func RandomColor() -> NSColor { NSColor(red: CGFloat(arc4random() % 255) / 255.0, green: CGFloat(arc4random() % 255) / 255.0, blue: CGFloat(arc4random() % 255) / 255.0, alpha: 1.0) }
public func RGBA(_ r: UInt8, _ g: UInt8, _ b: UInt8, _ a: CGFloat) -> NSColor { NSColor(red: CGFloat(r) / 255.0, green: CGFloat(g) / 255.0, blue: CGFloat(b) / 255.0, alpha: a) }
public func RGB(_ rgb: UInt8) -> NSColor { NSColor(red: CGFloat(rgb) / 255.0, green: CGFloat(rgb) / 255.0, blue: CGFloat(rgb) / 255.0, alpha: 1) }
public func Hex(_ hexValue: UInt) -> NSColor {
    NSColor(red: CGFloat((hexValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((hexValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(hexValue & 0x0000FF) / 255.0,
            alpha: 1.0)
}

public func BlackColorAlpha(_ a: CGFloat) -> NSColor { NSColor(white: 0, alpha: a) }
public func WhiteColorAlpha(_ a: CGFloat) -> NSColor { NSColor(white: 1, alpha: a) }
public func WhiteColor(_ white: CGFloat, alpha: CGFloat) -> NSColor { NSColor(white: white, alpha: alpha) }
