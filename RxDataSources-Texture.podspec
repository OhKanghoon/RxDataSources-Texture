#
# Be sure to run `pod lib lint RxTextureDataSources.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
    s.name             = 'RxDataSources-Texture'
    s.version          = '0.1.0'
    s.summary          = 'RxDataSources With Texture'
    
    # This description is used to generate tags and improve search results.
    #   * Think: What does it do? Why did you write it? What is the focus?
    #   * Try to keep it short, snappy and to the point.
    #   * Write the description between the DESC delimiters below.
    #   * Finally, don't worry about the indent, CocoaPods strips it!
    
    s.description      = 'RXDataSources With Texture'
    
    s.homepage         = 'https://github.com/OhKanghoon/RxDataSources-Texture'
    # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.author           = { 'OhKanghoon' => 'ggaa96@naver.com' }
    s.source           = { :git => 'https://github.com/OhKanghoon/RxDataSources-Texture.git', :tag => s.version.to_s }
    # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
    
    s.ios.deployment_target = '9.3'
    
    s.source_files = 'RxDataSources-Texture/Classes/**/*'
    
    s.dependency 'RxSwift', '~> 4.0'
    s.dependency 'RxCocoa', '~> 4.0'
    s.dependency 'Differentiator', '~> 3.0'
    s.dependency 'Texture', '~> 2.7'
end
