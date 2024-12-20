#
#  Be sure to run `pod spec lint YLCategory-Swift-MacOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

    s.name            = "YLCategory-Swift-MacOS"
    s.version         = "1.0.1"
    s.summary         = "MacOS 开发，常用的工具类"
    s.homepage        = "https://github.com/yulong000/YLCategory-Swift-MacOS"
    s.author          = { "魏宇龙" => "weiyulong1987@163.com" }
    s.platform        = :macos, "10.14"
    s.license         = { :type => 'MIT', :file => 'LICENSE'}
    s.requires_arc = true
    s.swift_versions  = ['5.0']
    s.source          = { :git => "https://github.com/yulong000/YLCategory-Swift-MacOS.git", :tag => "#{s.version}" }
    s.source_files    = "YLCategory-Swift-MacOS/YLCategory.h"
    s.requires_arc    = true
    s.static_framework = true

    s.subspec 'Other' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/Other/**/*.{h,m,swift}'
    ss.dependency        'YLCategory-Swift-MacOS/NSView'
    end

    s.subspec 'NSArray' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSArray/*.{h,m,swift}'
    end

    s.subspec 'NSWindow' do |ss|
    ss.source_files  =    'YLCategory-Swift-MacOS/NSWindow/*.{h,m,swift}'
    end

    s.subspec 'NSScreen' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSScreen/*.{h,m,swift}'
    end

    s.subspec 'NSView' do |ss|
    ss.source_files  =    'YLCategory-Swift-MacOS/NSView/*.{h,m,swift}'
    end

    s.subspec 'NSTextField' do |ss|
    ss.source_files  =    'YLCategory-Swift-MacOS/NSTextField/*.{h,m,swift}'
    end

    s.subspec 'NSString' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSString/*.{h,m,swift}'
    end

    s.subspec 'NSObject' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSObject/*.{h,m,swift}'
    end

    s.subspec 'NSImage' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSImage/*.{h,m,swift}'
    end

    s.subspec 'NSDate' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSDate/*.{h,m,swift}'
    end

    s.subspec 'NSControl' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSControl/*.{h,m,swift}'
    end

    s.subspec 'NSButton' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSButton/*.{h,m,swift}'
    ss.dependency        'YLCategory-Swift-MacOS/NSControl'
    end

    s.subspec 'NSAlert' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSAlert/*.{h,m,swift}'
    end

    s.subspec 'NSResponder' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSResponder/*.{h,m,swift}'
    ss.dependency        'YLCategory-Swift-MacOS/Other'
    end

    s.subspec 'NSColor' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSColor/*.{h,m,swift}'
    end

    s.subspec 'NSImageView' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/NSImageView/*.{h,m,swift}'
    end

    s.subspec 'YLHud' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLHud/*.{h,m,swift}'
    ss.resource      =   'YLCategory-Swift-MacOS/YLHud/Resources/*'
    ss.dependency        'YLCategory-Swift-MacOS/Other'
    end

    s.subspec 'YLShortcutView' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLShortcutView/**/*.{h,m,swift}'
    ss.resource      =   'YLCategory-Swift-MacOS/YLShortcutView/Resources/*'
    ss.dependency        'YLCategory-Swift-MacOS/YLHud'
    end

    s.subspec 'YLUserDefaults' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLUserDefaults/*.{h,m,swift}'
    end

    s.subspec 'YLWeakTimer' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLWeakTimer/*.{h,m,swift}'
    end

    s.subspec 'YLCollectionView' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLCollectionView/*.{h,m,swift}'
    end

    s.subspec 'YLAppleScript' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLAppleScript/*.{h,m,swift}'
    ss.resource      =   'YLCategory-Swift-MacOS/YLAppleScript/Resources/*'
    ss.dependency        'YLCategory-Swift-MacOS/YLHud'
    end

    s.subspec 'YLFlipView' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLFlipView/*.{h,m,swift}'
    end

    s.subspec 'YLCFNotificationManager' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLCFNotificationManager/*.{h,m,swift}'
    end

    s.subspec 'YLControl' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLControl/*.{h,m,swift}'
    end

    s.subspec 'YLUtility' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLUtility/*.{h,m,swift}'
    end

    s.subspec 'YLUpdateManager' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLUpdateManager/*.{h,m,swift}'
    ss.resource      =   'YLCategory-Swift-MacOS/YLUpdateManager/Resources/*'
    end

    s.subspec 'YLAppRating' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLAppRating/*.{h,m,swift}'
    end

    s.subspec 'YLWindowButton' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLWindowButton/*.{h,m,swift}'
    end

    s.subspec 'YLLanguage' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLLanguage/*.{h,m,swift}'
    ss.resource      =   'YLCategory-Swift-MacOS/YLLanguage/Resources/*'
    end

    s.subspec 'YLPermissionManager' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLPermissionManager/*.{h,m,swift}'
    ss.resource      =   'YLCategory-Swift-MacOS/YLPermissionManager/Resources/*'
    end

    s.subspec 'YLAppleReview' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLAppleReview/*.{h,m,swift}'
    end

    s.subspec 'YLFileAccess' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLFileAccess/**/*.{h,m,swift}'
    ss.resource      =   'YLCategory-Swift-MacOS/YLFileAccess/Resources/*'
    end
    
    s.subspec 'YLTextField' do |ss|
    ss.source_files  =   'YLCategory-Swift-MacOS/YLTextField/**/*.{h,m,swift}'
    end

end

# 升级时  1.add tag
#        2.push tag
#        3.pod trunk push YLCategory-Swift-MacOS.podspec --allow-warnings --use-libraries

#        pod spec lint YLCategory-Swift-MacOS.podspec --use-libraries  验证远端的podspec文件
#        pod lib lint YLCategory-Swift-MacOS.podspec --use-libraries   验证本地的podspec文件
#        --use-libraries 有第三方库依赖，添加该参数

#        pod trunk delete YLCategory-Swift-MacOS x.x.x  删除已发布的某个版本
