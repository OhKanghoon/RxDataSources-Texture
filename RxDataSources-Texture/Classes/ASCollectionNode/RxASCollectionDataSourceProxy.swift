//
//  RxASCollectionDataSourceProxy.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)

import UIKit
import AsyncDisplayKit
import RxSwift
import RxCocoa

extension ASCollectionNode: HasDataSource {
    public typealias DataSource = ASCollectionDataSource
}

fileprivate let collectionDataSourceNotSet = ASCollectionDataSourceNotSet()

final class ASCollectionDataSourceNotSet
    : NSObject
    , ASCollectionDataSource {
    
    func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return 0
    }
    
    func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        rxAbstractMethod(message: dataSourceNotSet)
    }
}

/// For more information take a look at `DelegateProxyType`.
final class RxASCollectionDataSourceProxy
    : DelegateProxy<ASCollectionNode, ASCollectionDataSource>
    , DelegateProxyType
    , ASCollectionDataSource {
    
    /// Typed parent object.
    public weak private(set) var collectionNode: ASCollectionNode?
    
    /// - parameter tableNode: Parent object for delegate proxy.
    public init(collectionNode: ASCollectionNode) {
        self.collectionNode = collectionNode
        super.init(parentObject: collectionNode, delegateProxy: RxASCollectionDataSourceProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxASCollectionDataSourceProxy(collectionNode: $0) }
    }
    
    fileprivate weak var _requiredMethodsDataSource: ASCollectionDataSource? = collectionDataSourceNotSet
    
    // MARK: DataSource
    
    /// Required datasource method implementation.
    public func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource
            ?? collectionDataSourceNotSet).collectionNode!(collectionNode, numberOfItemsInSection: section)
    }
    
    /// Required datasource method implementation.
    
    public func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        return (_requiredMethodsDataSource ?? collectionDataSourceNotSet).collectionNode!(collectionNode, nodeBlockForItemAt: indexPath)
    }
    
    public override func setForwardToDelegate(_ forwardToDelegate: ASCollectionDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate ?? collectionDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}
#endif
