Pod::Spec.new do |s|
  s.name     = 'ECShareKit'
  s.version  = '0.5.7'
  s.license  = 'MIT'
  s.ios.deployment_target = '6.0'

  s.summary  = 'ECShareKit for iOS.'
  s.homepage = 'https://github.com/mad-rabbid/ShareKit'
  s.authors  = { 'Sergey Samoylov' => 'mad.rabbid.78@gmail.com' }
  s.requires_arc = true

  s.source   = { :git  => 'git@gitlab.corp.mail.ru:emapp-ios-components/ecsharekit.git', :tag => s.version.to_s }
  s.source_files = 'ECShareKit/ShareKit/**/*.{h,m}'

  s.description = 'Framework to embedding a sharing option into iOS applications.'
  s.resource   = 'ECShareKit/Resources/ECShareKit.bundle'
  s.frameworks = 'Accounts', 'CoreGraphics', 'SystemConfiguration', 'Social', 'Twitter'

  s.dependency 'AFNetworking', '~> 2.0.1'
  s.dependency 'JSONKit', '~> 1.5'
  s.dependency 'FXKeychain', '~> 1.4'
  s.dependency 'NSData+Base64', '~> 1.0.0'
  s.dependency 'Toast', '~>2.1'
end