Pod::Spec.new do |s|
  s.name         = "UAParserSwift"
  s.version      = "1.0.1"
  s.summary      = "Lightweight User-Agent String Parser for Swift"
  s.description  = <<-DESC
    UAParserSwift is a Swift-based library to parse User Agent string; it's a port of ua-parser-js by Faisal Salman created to be mainly used in Swift Server Side applications (but compatible with all Apple's platforms too).
  DESC
  s.homepage     = "https://github.com/malcommac/UAParserSwift.git"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Daniele Margutti" => "me@danielemargutti.com" }
  s.social_media_url   = "http://twitter.com/danielemargutti"
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/malcommac/UAParserSwift.git", :tag => s.version.to_s }
  s.source_files  = "Sources/**/*"
  s.frameworks  = "Foundation"
end
