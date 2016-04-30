#
# Be sure to run `pod lib lint NCMB-Facebook-use-framework.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "NCMB-Facebook-use-framework"
  s.version          = "0.1.0"
  s.summary          = "NCMBでFacebookSDKがpodsのuse_frameworksを有効にしていると動かないことの回避"

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  NCMBでFacebookSDKがpodsのuse_frameworksを有効にしていると動かないことの回避をします。 iOSのSocialフレームワークを使ってFacebook情報を取得します。
                       DESC

  s.homepage         = "https://github.com/hiromi2424/NCMB-Facebook-use-framework"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "hiromi2424" => "hiromi2424@gmail.com" }
  s.source           = { :git => "https://github.com/hiromi2424/NCMB-Facebook-use-framework.git", :tag => s.version.to_s }
  s.social_media_url = 'https://twitter.com/hiromi2424'

  s.ios.deployment_target = '8.0'

  s.source_files = 'NCMB-Facebook-use-framework/Classes/**/*'
  
  # s.resource_bundles = {
  #   'NCMB-Facebook-use-framework' => ['NCMB-Facebook-use-framework/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Alamofire', '~> 3.3'
  s.dependency 'SwiftyJSON', '~> 2.3.0'
  s.dependency 'PromiseKit'

end
