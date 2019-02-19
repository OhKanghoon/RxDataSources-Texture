//
//  RxASTableDataSourceType.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)

import Foundation
import AsyncDisplayKit
import RxSwift

/// Marks data source as `ASTableNode` reactive data source enabling it to be used with one of the `bindTo` methods.
public protocol RxASTableDataSourceType /*: ASTableDataSource*/ {
    
    /// Type of elements that can be bound to table node.
    associatedtype Element
    
    /// New observable sequence event observed.
    ///
    /// - parameter tableView: Bound table node.
    /// - parameter observedEvent: Event
    func tableNode(_ tableNode: ASTableNode, observedEvent: Event<Element>) -> Void
}

#endif
