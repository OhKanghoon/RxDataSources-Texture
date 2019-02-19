//
//  RxASTableDelegateProxy.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

extension ASTableNode: HasDelegate {
    public typealias Delegate = ASTableDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxASTableDelegateProxy
    : DelegateProxy<ASTableNode, ASTableDelegate>
    , DelegateProxyType
    , ASTableDelegate {
    
    /// Typed parent object.
    public weak private(set) var tableNode: ASTableNode?
    
    /// - parameter tableNode: Parent object for delegate proxy.
    public init(tableNode: ASTableNode) {
        self.tableNode = tableNode
        super.init(parentObject: tableNode, delegateProxy: RxASTableDelegateProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxASTableDelegateProxy(tableNode: $0) }
    }
}

#endif
