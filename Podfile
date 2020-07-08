platform :ios, '11.0'


def common_pods
  
  # Tools
  pod 'SwiftLint'
  pod 'SwiftGen'
  
  pod 'RealmSwift', '~> 5.2.0'
  
  # Rx
  pod 'RxSwift', '~> 5'
  pod 'RxCocoa', '~> 5'
  pod 'RxRealm', '~> 3.1.0'
  pod 'RxDataSources', '~> 4.0'
  
end

def test_pods
  pod 'RxBlocking', '~> 5'
  pod 'RxTest', '~> 5'
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
