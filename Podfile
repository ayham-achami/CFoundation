# Sources
source 'https://github.com/CocoaPods/specs.git'

install! 'cocoapods', :warn_for_unused_master_specs_repo => false

# Project
project 'CFoundation.xcodeproj'

# Uncomment the next line to define a global platform for your project
platform :ios, '11.0'

target 'CFoundation' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for CFoundation
  pod 'SwiftLint'

  target 'CFoundationTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.build_configurations.each do |config|
    config.build_settings["EXCLUDED_ARCHS[sdk=iphonesimulator*]"] = "arm64"
  end
end
