platform :ios, '13.0'


def common_pods
  
  # Tools
  pod 'SwiftLint'
  pod 'SwiftGen'
  
  pod 'RealmSwift', '~> 10.32.0'
  
  # Rx
  pod 'RxSwift', '~> 6.5'
  pod 'RxCocoa', '~> 6.5'
  pod 'RxRealm', '~> 5'
  pod 'RxDataSources', '~> 5'
  
  # UI
  pod 'lottie-ios'
  
end

def test_pods
  pod 'RxBlocking', '~> 6.5'
  pod 'RxTest', '~> 6.5'
end

target 'NorrisFacts' do
  use_frameworks!
  
  common_pods
  
  target 'NorrisFactsTests' do
    inherit! :search_paths
    test_pods
  end

  target 'NorrisFactsUITests' do
    test_pods
  end

end
