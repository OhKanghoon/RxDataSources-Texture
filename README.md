<img src="https://github.com/OhKanghoon/RxDataSources-Texture/blob/master/Resource/logo.png">

![Swift](https://img.shields.io/badge/Swift-5.1-orange.svg)
[![Build Status](https://github.com/OhKanghoon/RxDataSources-Texture/workflows/CI/badge.svg)](https://github.com/OhKanghoon/RxDataSources-Texture/actions)
[![Version](https://img.shields.io/cocoapods/v/RxDataSources-Texture.svg?style=flat)](https://cocoapods.org/pods/RxDataSources-Texture)
[![License](https://img.shields.io/cocoapods/l/RxDataSources-Texture.svg?style=flat)](https://cocoapods.org/pods/RxDataSources-Texture)
[![Platform](https://img.shields.io/cocoapods/p/RxDataSources-Texture.svg?style=flat)](https://cocoapods.org/pods/RxDataSources-Texture)

## Usage

1. Turn your data into an Observable sequence
2. Bind the data to the tableNode / collectionNode using :
- rx.items(dataSource:protocol<RxASTableDataSourceType, ASTableDataSource>)

```swift
let dataSource = RxASTableSectionedReloadDataSource<SectionModel<String, Int>>(
    configureCellBlock: { (_, _, _, num) in
        return {
            let cell = ASTextCellNode()
            cell.text = "\(num)"
            return cell
        }
})

Observable.just([SectionModel(model: "title", items: [1, 2, 3])])
    .bind(to: tableNode.rx.items(dataSource: dataSource))
    .disposed(by: disposeBag)
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.
- [RxDataSources Example](https://github.com/OhKanghoon/RxDataSources-Texture/tree/master/Example)

## Requirements

- Swift 5.2
- [RxSwift](https://github.com/ReactiveX/RxSwift) (~> 6.0)
- [RxCocoa](https://github.com/ReactiveX/RxSwift/tree/master/RxCocoa) (~> 6.0)
- Differentiator (~> 5.0)
- [Texture](https://github.com/TextureGroup/Texture) (~> 3.0)

## Installation

RxDataSources-Texture is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'RxDataSources-Texture'
```

## Development

```console
$ make project
$ open RxDataSources-Texture.xcworkspace
```

## Author

OhKanghoon, ggaa96@naver.com

## License

RxDataSources-Texture is available under the MIT license. See the LICENSE file for more info.
