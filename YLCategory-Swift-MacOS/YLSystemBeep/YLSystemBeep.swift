//
//  YLSystemBeep.swift
//  YLCategory-Swift-MacOS
//
//  Created by 魏宇龙 on 2025/7/14.
//

import Foundation
import AudioToolbox

public class YLSystemBeep {
    
    static let shared = YLSystemBeep()
    // 提示音音量
    var beepVolumeValue: Float = 0
    // 收到提示音回调
    public var receivedBeepHandler: (() -> Void)?
    
    // MARK: 关闭系统提示音
    public func closeSystemBeep() {
        setSystemBeepVolume(0.001)
    }
    
    // MARK: 打开系统提示音
    public func openSystemBeep() {
        setSystemBeepVolume(beepVolumeValue)
    }
    
    // MARK: 获取系统提示音音量, ⚠️ 只在 setSystemBeepVolume 未调用之前有效，一旦改了，会把更改的值缓存，下次获取到的值是上次的值，而不是最新的，需要通过脚本去获取
    public func getSystemBeepVolume() -> Float {
        var volume: Float = 0
        var volSize = UInt32(MemoryLayout.size(ofValue: volume))
        let err = AudioServicesGetProperty(kAudioServicesPropertySystemAlertVolume, 0, nil, &volSize, &volume)
        if err != noErr {
            print("Error getting alert volume: \(err)")
            return .nan
        }
        return volume
    }
    
    // MARK: 设置系统提示音音量
    public func setSystemBeepVolume(_ volume: Float32) {
        var v = volume
        AudioServicesSetProperty(kAudioServicesPropertySystemAlertVolume, 0, nil, UInt32(MemoryLayout.size(ofValue: volume)), &v)
    }
    
    // MARK: - private

    private init() {
        beepVolumeValue = getSystemBeepVolume()
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(systemBeepNotification), name: NSNotification.Name(rawValue:"com.apple.systemBeep"), object: nil)
        DistributedNotificationCenter.default().addObserver(self, selector: #selector(alertVolumeChanged), name: NSNotification.Name(rawValue:"com.apple.sound.alertVolumeChanged"), object: nil)
    }
    deinit {
        DistributedNotificationCenter.default().removeObserver(self)
    }
    
    @objc private func systemBeepNotification(_ noti: Notification) {
        receivedBeepHandler?()
    }
    
    @objc private func alertVolumeChanged(_ noti: Notification) {
        refreshSystemBeepVolume()
    }
    
    private let kAudioServicesPropertySystemAlertVolume: AudioServicesPropertyID = OSType("ssvl".utf8.reduce(0) { ($0 << 8) | FourCharCode($1)})
    private var refreshSystemBeepVolume: () -> Void = {
        var index = 0
        return {
            let currentIndex = index + 1
            index = currentIndex
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if currentIndex == index {
                    defer {
                        index = 0
                    }
                    let process = Process()
                    process.executableURL = URL(fileURLWithPath: "/bin/bash")
                    process.arguments = ["-c", "defaults read -g com.apple.sound.beep.volume"]
                    
                    let outputPipe = Pipe()
                    let errorPipe = Pipe()
                    process.standardOutput = outputPipe
                    process.standardError = errorPipe
                    do {
                        try process.run()
                    } catch {
                        print("❌ refreshSystemBeepVolume' 发生错误: \(error)")
                        return
                    }
                    process.waitUntilExit()
                    
                    let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
                    let errorData = errorPipe.fileHandleForReading.readDataToEndOfFile()
                    
                    let output = String(data: outputData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    let errorOutput = String(data: errorData, encoding: .utf8)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
                    
                    if process.terminationStatus != 0 {
                        YLLog("❌ refreshSystemBeepVolume 执行失败: \(errorOutput)")
                        return
                    }
                    YLLog("✅ refreshSystemBeepVolume 执行成功: \(output)")
                    
                    if let value = Float(output) {
                        YLSystemBeep.shared.beepVolumeValue = value
                    }
                }
            }
        }
    }()
    
}
