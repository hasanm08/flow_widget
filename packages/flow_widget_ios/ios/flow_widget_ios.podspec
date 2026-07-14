#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flow_widget_ios'
  s.version          = '1.0.2'
  s.summary          = 'iOS implementation of the flow_widget Flutter plugin.'
  s.description      = <<-DESC
Federated iOS implementation providing shared storage, WidgetKit updates,
and ActivityKit Live Activities for flow_widget.
                       DESC
  s.homepage         = 'https://github.com/hasanm08/flow_widget'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Flow Widget' => 'support@flow-widget.dev' }
  s.source           = { :path => '.' }
  s.source_files     = 'flow_widget_ios/Sources/flow_widget_ios/**/*.swift'
  s.dependency 'Flutter'
  s.platform         = :ios, '14.0'
  s.swift_version    = '5.0'
  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES',
    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386'
  }
  s.resource_bundles = {
    'flow_widget_ios_privacy' => [
      'flow_widget_ios/Sources/flow_widget_ios/Resources/PrivacyInfo.xcprivacy'
    ]
  }
  s.weak_frameworks = 'ActivityKit', 'WidgetKit'
end
