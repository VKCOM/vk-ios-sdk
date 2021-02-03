Pod::Spec.new do |s|
  s.name         = "VK-ios-sdk"
  s.version      = "1.6.2"
  s.summary      = "Library for working with VK."
  s.homepage     = "https://github.com/VKCOM/vk-ios-sdk"
  s.license      = 'MIT'
  s.author       = { "Roman Truba" => "dreddkr@gmail.com" }
  s.platform     = :ios, '8.0'
  s.source       = { :git => "https://github.com/VKCOM/vk-ios-sdk.git", :tag => s.version.to_s }
  s.source_files = 'library/source/**/*.{h,m}'
  s.public_header_files = 'library/source/**/*.h'
  s.resource_bundles = {
    'VKSdkResources' => ['library/Resources/SdkAssetCatalog.xcassets','library/Resources/*.lproj']
  }
  s.frameworks    = 'Foundation','UIKit','SafariServices','CoreGraphics','Security'
  s.requires_arc = true
end
