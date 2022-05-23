#
# Be sure to run `pod lib lint KTVGrab.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KTVGrab'
  s.version          = '0.1.0'
  s.summary          = 'KTV 抢唱业务场景'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/zegoim/ZegoKTVGrab-iOS'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Vic' => 'vicwan@zego.im' }
  s.source           = { :git => 'git@github.com:zegoim/ZegoKTVGrab-iOS.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'
  s.source_files = 'KTVGrab/Classes/**/*'
  s.resource_bundles = {
    'KTVGrab' => ['KTVGrab/Assets/*.{xcassets}', 'KTVGrab/Assets/Resources/*']
  }
  
  s.prefix_header_contents = '#import "GBInternalHeader.h"'
  
  s.dependency 'Masonry'
  s.dependency 'YYKit'
  s.dependency 'LEEAlert'
  s.dependency 'YTKNetwork'
  s.dependency 'lottie-ios'
  s.dependency 'MBProgressHUD'
  s.dependency 'ZegoNetwork'
  s.dependency 'IQKeyboardManager'
  s.dependency 'MJRefresh'
  s.dependency 'ZegoLyricView'
  s.dependency 'ZegoPitchView'
  s.dependency 'lottie-ios'
  s.dependency 'GZIP', '~> 1.3.0'
  s.dependency 'Toast'
  s.dependency 'GoKit'
  s.dependency 'MessageThrottle'
  
end
