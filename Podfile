project 'PashuCare.xcodeproj'

platform :ios, '13.0'

target 'PashuCare' do
  use_frameworks!

  pod 'TensorFlowLiteC', '2.13.0'
  pod 'TensorFlowLiteSwift', '2.13.0'

  post_install do |installer|
    installer.pods_project.targets.each do |target|
      target.build_configurations.each do |config|
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
      end
    end
  end
end
