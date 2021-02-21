require "json"

package = JSON.parse(File.read(File.join(__dir__, "package.json")))

Pod::Spec.new do |s|
  s.name         = "react-native-rongcloud"
  s.version      = package["version"]
  s.summary      = package["description"]
  s.description  = <<-DESC
                  react-native-rongcloud
                   DESC
  s.homepage     = "https://github.com/github_account/react-native-rongcloud"
  # brief license entry:
  s.license      = "MIT"
  # optional - use expanded license entry instead:
  # s.license    = { :type => "MIT", :file => "LICENSE" }
  s.authors      = { "Your Name" => "yourname@email.com" }
  s.platforms    = { :ios => "9.0" }
  s.source       = { :git => "https://github.com/github_account/react-native-rongcloud.git", :tag => "#{s.version}" }

  s.source_files = "ios/**/*.{h,c,m,swift}"
  s.requires_arc = true

  s.dependency "React"
  # ...
  s.dependency 'RongCloudIM/IMKit', '~> 4.0.3.3'
  s.dependency 'RongCloudIM/IMLib', '~> 4.0.3.3'
  s.dependency 'AFNetworking/Serialization', '3.2.1'
  s.dependency 'AFNetworking/Security', '3.2.1'
  s.dependency 'AFNetworking/NSURLSession', '3.2.1'
  s.dependency 'AFNetworking/Reachability', '3.2.1'
end

