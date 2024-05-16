#
# Be sure to run `pod lib lint UpgameVideoFramework.podspec' to ensure this is a
# valid spec before submitting.
#

Pod::Spec.new do |s|
    s.name             = 'UpgameVideoFramework'
    s.version          = '1.0.8'
    s.summary          = 'Cocoapods compatible version of UpgameVideoFramework.'
    s.swift_version    = '5.0'

    s.description      = <<-DESC
    Cocoapods compatible version of UpgameVideoFramework. UpgameVideoFramework is the feature that allows video analysis and telestrations in the Upgame app.
    DESC
    
    s.homepage         = 'git@github.com:golfgenius/upgame_ios_telestration.git'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'ArshAulakh59' => 'arsh@upgame.co' }
    s.source           = { :git => 'git@github.com:golfgenius/upgame_ios_telestration.git', :tag => s.version.to_s }
    s.vendored_frameworks = "UpgameVideoFramework.xcframework"
    s.ios.deployment_target = '13.0'
    
end
