Pod::Spec.new do |s|
  s.name             = 'MantleXMLExtension'
  s.version          = '1.2.3'
  s.summary          = 'MantleXMLExtension support mutual conversion between Model object and XML with Mantle.'
  s.homepage         = 'https://github.com/soranoba/MantleXMLExtension'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'soranoba' => 'soranoba@gmail.com' }
  s.source           = { :git => 'https://github.com/soranoba/MantleXMLExtension.git', :tag => s.version.to_s }

  s.ios.deployment_target = '9.0'

  s.source_files         = 'MantleXMLExtension/Classes/**/*.{m,h}'
  s.private_header_files = 'MantleXMLExtension/Classes/Private/*.h'

  s.dependency 'Mantle', '~> 2.0', '< 2.1.6'
end
