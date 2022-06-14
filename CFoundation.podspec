Pod::Spec.new do |spec|
  spec.name         = "CFoundation"
  spec.version      = "1.0.0"
  spec.summary      = "Компоненты и утилиты для iOS"
  spec.description  = <<-DESC
  Библиотека содержит основные компоненты и утилиты для создания iOS приложения
                   DESC
  spec.homepage     = ""
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.author       = { "Ayham Hylam" => "Ayham Hylam" }
  spec.homepage     = "https://github.com/ayham-achami/CFoundation"
  spec.ios.deployment_target = "13.0"
  spec.source       = { 
    :git => "git@github.com:ayham-achami/CFoundation.git", 
    :tag => spec.version.to_s 
  }
  spec.frameworks   = "Foundation"
  spec.source_files  = "Sources/**/*.swift"
  spec.requires_arc = true
  spec.swift_versions = ['5.0', '5.1']
  spec.pod_target_xcconfig = { "SWIFT_VERSION" => "5" }
  spec.pod_target_xcconfig = { 'APPLICATION_EXTENSION_API_ONLY' => 'YES' }
end
