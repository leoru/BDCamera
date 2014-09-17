Pod::Spec.new do |s|
  s.name         = "BDCamera"
  s.version      = "0.2"
  s.summary      = "BDCamera is a simple camera with AVFoundation"
  s.homepage     = "https://github.com/Borodutch/BDCamera"
  s.license      = 'MIT'
  s.author       = { "leoru" => "kirillkunst@gmail.com" }
  s.requires_arc = true
  s.ios.deployment_target = '7.0'
  s.source       = { :git => "https://github.com/Borodutch/BDCamera.git", :tag => "v0.2" }
  s.source_files = 'BDCamera/**/*.{h,m}'
end