Pod::Spec.new do |s|
  s.name = 'ChatwootSDK'
  s.version = '0.1.0'
  s.summary = 'Native Chatwoot support for iOS apps'
  s.homepage = 'https://www.chatwoot.com'
  s.license = { :type => 'MIT', :file => 'LICENSE' }
  s.author = 'Chatwoot Inc.'
  s.source = { :git => 'https://github.com/chatwoot/ios-sdk.git', :tag => s.version.to_s }
  s.platform = :ios, '17.0'
  s.swift_version = '5.9'
  s.source_files = 'Sources/ChatwootSDK/**/*.swift'
  s.resource_bundles = { 'ChatwootSDK' => ['Sources/ChatwootSDK/Resources/*'] }
end
