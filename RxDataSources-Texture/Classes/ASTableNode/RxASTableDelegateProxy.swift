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

    fileprivate var _contentOffsetBehaviorSubject: BehaviorSubject<CGPoint>?
    fileprivate var _contentOffsetPublishSubject: PublishSubject<()>?

    /// Optimized version used for observing content offset changes.
    internal var contentOffsetBehaviorSubject: BehaviorSubject<CGPoint> {
        if let subject = _contentOffsetBehaviorSubject {
            return subject
        }

        let subject = BehaviorSubject<CGPoint>(value: self.tableNode?.contentOffset ?? CGPoint.zero)
        _contentOffsetBehaviorSubject = subject

        return subject
    }

    /// Optimized version used for observing content offset changes.
    internal var contentOffsetPublishSubject: PublishSubject<()> {
        if let subject = _contentOffsetPublishSubject {
            return subject
        }

        let subject = PublishSubject<()>()
        _contentOffsetPublishSubject = subject

        return subject
    }

    // MARK: delegate methods

    /// For more information take a look at `DelegateProxyType`.
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let subject = _contentOffsetBehaviorSubject {
            subject.on(.next(scrollView.contentOffset))
        }
        if let subject = _contentOffsetPublishSubject {
            subject.on(.next(()))
        }
        self._forwardToDelegate?.scrollViewDidScroll?(scrollView)
    }

    deinit {
        if let subject = _contentOffsetBehaviorSubject {
            subject.on(.completed)
        }

        if let subject = _contentOffsetPublishSubject {
            subject.on(.completed)
        }
    }
}

#endif
