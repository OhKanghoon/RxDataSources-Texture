//
//  RxASCollectionDelegateProxy.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

extension ASCollectionNode: HasDelegate {
    public typealias Delegate = ASCollectionDelegate
}

/// For more information take a look at `DelegateProxyType`.
open class RxASCollectionDelegateProxy
    : DelegateProxy<ASCollectionNode, ASCollectionDelegate>
    , DelegateProxyType
    , ASCollectionDelegate {
    
    /// Typed parent object.
    public weak private(set) var collectionNode: ASCollectionNode?
    
    /// - parameter tableNode: Parent object for delegate proxy.
    public init(collectionNode: ASCollectionNode) {
        self.collectionNode = collectionNode
        super.init(parentObject: collectionNode, delegateProxy: RxASCollectionDelegateProxy.self)
    }
    
    // Register known implementations
    public static func registerKnownImplementations() {
        self.register { RxASCollectionDelegateProxy(collectionNode: $0) }
    }
}

#endif
