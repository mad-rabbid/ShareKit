Pod::Spec.new do |s|
  s.name     = 'ECShareKit'
  s.version  = '0.5'
  s.platform = :ios, '6.0'
  s.summary  = 'ECShareKit for iOS.'
  s.homepage = 'https://github.com/mad-rabbid/ShareKit'
  s.authors  = { 'Sergey Samoylov' => 'mad.rabbid.78@gmail.com' }
  
  s.source   = { :git  => 'https://github.com/mad-rabbid/ShareKit.git', :tag => s.version.to_s }
  s.source_files = 'ECShareKit/ECShareKit/ShareKit/**/*.{h,m}'

  s.description = 'Framework to embedding a sharing option into iOS applications.'
  s.platform = :ios
  s.resource   = 'ECShareKit/ECShareKit/Resources/ECShareKit.bundle'
  s.frameworks = 'Accounts', 'CoreGraphics', 'SystemConfiguration', 'Social', 'Twitter'

  s.dependency 'AFNetworking', '~> 2.0.1'
  s.dependency 'JSONKit', :git => 'https://github.com/mad-rabbid/JSONKit.git'
  s.dependency 'FXKeychain', '~> 1.4'
  s.dependency 'NSData+Base64', '~> 1.0.0'
  s.dependency 'Toast', '~>2.1'
end