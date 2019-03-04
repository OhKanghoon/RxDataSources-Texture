#
# Be sure to run `pod lib lint RxTextureDataSources.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'RxDataSources-Texture'
    s.version          = '1.0.0'
    s.summary          = 'RxDataSources With Texture'
    s.description      = <<-DESC
    This is a collection of reactive data sources for ASTableNode and ASCollectionNode
    DESC
    s.homepage         = 'https://github.com/OhKanghoon/RxDataSources-Texture'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'OhKanghoon' => 'ggaa96@naver.com' }
    s.source           = { :git => 'https://github.com/OhKanghoon/RxDataSources-Texture.git', :tag => s.version.to_s }
    
    s.ios.deployment_target = '9.0'
    s.requires_arc = true
    
    s.source_files = 'RxDataSources-Texture/Classes/**/*'
    
    s.dependency 'RxSwift', '~> 4.0'
    s.dependency 'RxCocoa', '~> 4.0'
    s.dependency 'Differentiator', '~> 3.0'
    s.dependency 'Texture', '~> 2.7'
end
