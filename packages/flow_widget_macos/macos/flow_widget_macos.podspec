#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#
Pod::Spec.new do |s|
  s.name             = 'flow_widget_macos'
  s.version          = '1.0.2'
  s.summary          = 'macOS implementation of the flow_widget plugin.'
  s.description      = <<-DESC
Provides WidgetKit timeline reloads and App Group shared storage for macOS
desktop widgets managed by flow_widget.
                       DESC
  s.homepage         = 'https://github.com/hasanm08/flow_widget'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'flow_widget' => 'dev@flowwidget.dev' }
  s.source           = { :path => '.' }
  s.source_files     = 'flow_widget_macos/Sources/flow_widget_macos/**/*.swift'
  s.dependency 'FlutterMacOS'
  s.platform = :osx, '11.0'
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES' }
  s.swift_version = '5.0'
end
