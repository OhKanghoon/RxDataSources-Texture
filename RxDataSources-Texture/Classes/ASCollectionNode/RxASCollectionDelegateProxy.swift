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
    , ASCollectionDelegate
    , ASCollectionDelegateFlowLayout {
    
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

    fileprivate var _contentOffsetBehaviorSubject: BehaviorSubject<CGPoint>?
    fileprivate var _contentOffsetPublishSubject: PublishSubject<()>?

    /// Optimized version used for observing content offset changes.
    internal var contentOffsetBehaviorSubject: BehaviorSubject<CGPoint> {
        if let subject = _contentOffsetBehaviorSubject {
            return subject
        }

        let subject = BehaviorSubject<CGPoint>(value: self.collectionNode?.contentOffset ?? CGPoint.zero)
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
