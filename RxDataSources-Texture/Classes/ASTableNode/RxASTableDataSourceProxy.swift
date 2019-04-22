//
//  RxASTableDataSourceProxy.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)

import UIKit
import AsyncDisplayKit
import RxSwift
import RxCocoa

extension ASTableNode: HasDataSource {
    public typealias DataSource = ASTableDataSource
}

fileprivate let tableDataSourceNotSet = ASTableDataSourceNotSet()

final class ASTableDataSourceNotSet
    : NSObject
    , ASTableDataSource {
    
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        rxAbstractMethod(message: dataSourceNotSet)
    }
}

/// For more information take a look at `DelegateProxyType`.
final class RxASTableDataSourceProxy
    : DelegateProxy<ASTableNode, ASTableDataSource>
    , DelegateProxyType
    , ASTableDataSource {

    /// Typed parent object.
    public weak private(set) var tableNode: ASTableNode?
    
    /// - parameter tableNode: Parent object for delegate proxy.
    public init(tableNode: ASTableNode) {
        self.tableNode = tableNode
        super.init(parentObject: tableNode, delegateProxy: RxASTableDataSourceProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxASTableDataSourceProxy(tableNode: $0) }
    }
    
    fileprivate weak var _requiredMethodsDataSource: ASTableDataSource? = tableDataSourceNotSet
    
    // MARK: DataSource
    
    /// Required datasource method implementation.
    public func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return (_requiredMethodsDataSource
            ?? tableDataSourceNotSet).tableNode!(tableNode, numberOfRowsInSection: section)
    }
    
    /// Required datasource method implementation.
    public func tableNode(_ tableNode: ASTableNode, nodeBlockForRowAt indexPath: IndexPath) -> ASCellNodeBlock {
        return (_requiredMethodsDataSource ?? tableDataSourceNotSet).tableNode!(tableNode, nodeBlockForRowAt: indexPath)
    }
    
    public override func setForwardToDelegate(_ forwardToDelegate: ASTableDataSource?, retainDelegate: Bool) {
        _requiredMethodsDataSource = forwardToDelegate ?? tableDataSourceNotSet
        super.setForwardToDelegate(forwardToDelegate, retainDelegate: retainDelegate)
    }
}
#endif
