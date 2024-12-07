#
#  Be sure to run `pod spec lint YLCategory-Swift-MacOS.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|

  s.name            = "YLCategory-Swift-MacOS"
  s.version         = "1.0.0"
  s.summary         = "MacOS 开发，常用的工具类"
  s.homepage        = "https://github.com/yulong000/YLCategory-Swift-MacOS"
  s.author          = { "魏宇龙" => "weiyulong1987@163.com" }
  s.platform        = :macos, "10.14"
  s.license         = { :type => 'MIT', :file => 'LICENSE' }
  s.swift_versions  = ['5.0']
  s.source          = { :git => "https://github.com/yulong000/YLCategory-Swift-MacOS.git", :tag => "#{s.version}" }
  s.source_files    = "YLCategory-Swift-MacOS/**/*.{swift, h, m}"
  s.requires_arc    = true

end

# 升级时  1.add tag
#        2.push tag
#        3.pod trunk push YLCategory-Swift-MacOS.podspec --allow-warnings --use-libraries

#        pod spec lint YLCategory-Swift-MacOS.podspec --use-libraries  验证podspec文件
#        --use-libraries 有第三方库依赖，添加该参数

#        pod trunk delete YLCategory-Swift-MacOS x.x.x  删除已发布的某个版本
