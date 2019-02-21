//
//  RxASCollectionDataSourceType.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)

import Foundation
import AsyncDisplayKit
import RxSwift

/// Marks data source as `ASCollectionNode` reactive data source enabling it to be used with one of the `bindTo` methods.
public protocol RxASCollectionDataSourceType /*: ASCollectionDataSource*/ {
    
    /// Type of elements that can be bound to table node.
    associatedtype Element
    
    /// New observable sequence event observed.
    ///
    /// - parameter collectionNode: Bound collection node.
    /// - parameter observedEvent: Event
    func collectionNode(_ collectionNode: ASCollectionNode, observedEvent: Event<Element>) -> Void
}

#endif
