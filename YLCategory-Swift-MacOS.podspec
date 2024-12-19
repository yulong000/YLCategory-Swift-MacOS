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
    s.source_files    = "YLCategory-MacOS/YLCategory.h"
    s.requires_arc    = true
    s.static_framework = true

    s.subspec 'Other' do |ss|
    ss.source_files  =   'YLCategory-MacOS/Other/**/*.{h,m,swift}'
    ss.dependency        'YLCategory-MacOS/NSView'
    end

    s.subspec 'NSArray' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSArray/*.{h,m,swift}'
    end

    s.subspec 'NSWindow' do |ss|
    ss.source_files  =    'YLCategory-MacOS/NSWindow/*.{h,m,swift}'
    end

    s.subspec 'NSScreen' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSScreen/*.{h,m,swift}'
    end

    s.subspec 'NSView' do |ss|
    ss.source_files  =    'YLCategory-MacOS/NSView/*.{h,m,swift}'
    end

    s.subspec 'NSTextField' do |ss|
    ss.source_files  =    'YLCategory-MacOS/NSTextField/*.{h,m,swift}'
    end

    s.subspec 'NSString' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSString/*.{h,m,swift}'
    end

    s.subspec 'NSObject' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSObject/*.{h,m,swift}'
    end

    s.subspec 'NSImage' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSImage/*.{h,m,swift}'
    end

    s.subspec 'NSDate' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSDate/*.{h,m,swift}'
    end

    s.subspec 'NSControl' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSControl/*.{h,m,swift}'
    end

    s.subspec 'NSButton' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSButton/*.{h,m,swift}'
    ss.dependency        'YLCategory-MacOS/NSControl'
    end

    s.subspec 'NSAlert' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSAlert/*.{h,m,swift}'
    end

    s.subspec 'NSResponder' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSResponder/*.{h,m,swift}'
    ss.dependency        'YLCategory-MacOS/Other'
    end

    s.subspec 'NSColor' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSColor/*.{h,m,swift}'
    end

    s.subspec 'NSImageView' do |ss|
    ss.source_files  =   'YLCategory-MacOS/NSImageView/*.{h,m,swift}'
    end

    s.subspec 'YLHud' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLHud/*.{h,m,swift}'
    ss.resource      =   'YLCategory-MacOS/YLHud/Resources/*'
    ss.dependency        'YLCategory-MacOS/Other'
    end

    s.subspec 'YLShortcutView' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLShortcutView/**/*.{h,m,swift}'
    ss.resource      =   'YLCategory-MacOS/YLShortcutView/Resources/*'
    ss.dependency        'YLCategory-MacOS/YLHud'
    end

    s.subspec 'YLUserDefaults' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLUserDefaults/*.{h,m,swift}'
    end

    s.subspec 'YLWeakTimer' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLWeakTimer/*.{h,m,swift}'
    end

    s.subspec 'YLCollectionView' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLCollectionView/*.{h,m,swift}'
    end

    s.subspec 'YLAppleScript' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLAppleScript/*.{h,m,swift}'
    ss.resource      =   'YLCategory-MacOS/YLAppleScript/Resources/*'
    ss.dependency        'YLCategory-MacOS/YLHud'
    end

    s.subspec 'YLFlipView' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLFlipView/*.{h,m,swift}'
    end

    s.subspec 'YLCFNotificationManager' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLCFNotificationManager/*.{h,m,swift}'
    end

    s.subspec 'YLControl' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLControl/*.{h,m,swift}'
    end

    s.subspec 'YLUtility' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLUtility/*.{h,m,swift}'
    end

    s.subspec 'YLUpdateManager' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLUpdateManager/*.{h,m,swift}'
    ss.resource      =   'YLCategory-MacOS/YLUpdateManager/Resources/*'
    end

    s.subspec 'YLAppRating' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLAppRating/*.{h,m,swift}'
    end

    s.subspec 'YLWindowButton' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLWindowButton/*.{h,m,swift}'
    end

    s.subspec 'YLLanguage' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLLanguage/*.{h,m,swift}'
    ss.resource      =   'YLCategory-MacOS/YLLanguage/Resources/*'
    end

    s.subspec 'YLPermissionManager' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLPermissionManager/*.{h,m,swift}'
    ss.resource      =   'YLCategory-MacOS/YLPermissionManager/Resources/*'
    end

    s.subspec 'YLAppleReview' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLAppleReview/*.{h,m,swift}'
    end

    s.subspec 'YLFileAccess' do |ss|
    ss.source_files  =   'YLCategory-MacOS/YLFileAccess/**/*.{h,m,swift}'
    ss.resource      =   'YLCategory-MacOS/YLFileAccess/Resources/*'
    end


end

# 升级时  1.add tag
#        2.push tag
#        3.pod trunk push YLCategory-Swift-MacOS.podspec --allow-warnings --use-libraries

#        pod spec lint YLCategory-Swift-MacOS.podspec --use-libraries  验证远端的podspec文件
#        pod lib lint YLCategory-Swift-MacOS.podspec --use-libraries   验证本地的podspec文件
#        --use-libraries 有第三方库依赖，添加该参数

#        pod trunk delete YLCategory-Swift-MacOS x.x.x  删除已发布的某个版本
