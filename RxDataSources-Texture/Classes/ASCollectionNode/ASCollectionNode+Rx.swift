//
//  ASCollectionNode+Rx.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

// Items

extension Reactive where Base: ASCollectionNode {
    
    /**
     Binds sequences of elements to collection node items using a custom reactive data used to perform the transformation.
     
     - parameter dataSource: Data source used to transform elements to cell nodes.
     - parameter source: Observable sequence of items.
     - returns: Disposable object that can be used to unbind.
     
     */
    public func items<
        DataSource: RxASCollectionDataSourceType & ASCollectionDataSource,
        O: ObservableType>
        (dataSource: DataSource)
        -> (_ source: O)
        -> Disposable where DataSource.Element == O.E {
            return { source in
                return source.subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource, retainDataSource: true) { [weak collectionNode = self.base] (_: RxASCollectionDataSourceProxy, event) -> Void in
                    guard let collectionNode = collectionNode else {
                        return
                    }
                    dataSource.collectionNode(collectionNode, observedEvent: event)
                }
            }
    }
}

extension Reactive where Base: ASCollectionNode {
    
    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var delegate: DelegateProxy<ASCollectionNode, ASCollectionDelegate> {
        return RxASCollectionDelegateProxy.proxy(for: base)
    }
    
    /**
     Reactive wrapper for `dataSource`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var dataSource: DelegateProxy<ASCollectionNode, ASCollectionDataSource> {
        return RxASCollectionDataSourceProxy.proxy(for: base)
    }
    
    /**
     Installs data source as forwarding delegate on `rx.dataSource`.
     Data source won't be retained.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter dataSource: Data source object.
     - returns: Disposable object that can be used to unbind the data source.
     */
    public func setDataSource(_ dataSource: ASCollectionDataSource)
        -> Disposable {
            return RxASCollectionDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: self.base)
    }
    
    /**
     Installs delegate as forwarding delegate on `rx.delegate`.
     Data source won't be retained.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter delegate: Delegate object
     - returns: Disposable object that can be used to unbind the delegate.
     */
    public func setDelegate(_ delegate: ASCollectionDelegate)
        -> Disposable {
            return RxASCollectionDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }

    /// Reactive wrapper for `contentOffset`.
    public var contentOffset: ControlProperty<CGPoint> {
        let proxy = RxASCollectionDelegateProxy.proxy(for: base)

        let bindingObserver = Binder(self.base) { collectionNode, contentOffset in
            collectionNode.contentOffset = contentOffset
        }

        return ControlProperty(values: proxy.contentOffsetBehaviorSubject, valueSink: bindingObserver)
    }

    /// Reactive wrapper for delegate method `scrollViewDidScroll`
    public var didScroll: ControlEvent<Void> {
        let source = RxASCollectionDelegateProxy.proxy(for: base).contentOffsetPublishSubject
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewWillBeginDecelerating`
    public var willBeginDecelerating: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.scrollViewWillBeginDecelerating(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewDidEndDecelerating`
    public var didEndDecelerating: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.scrollViewDidEndDecelerating(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewWillBeginDragging`
    public var willBeginDragging: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.scrollViewWillBeginDragging(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)`
    public var willEndDragging: ControlEvent<WillEndDraggingEvent> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)))
            .map { value -> WillEndDraggingEvent in
                let velocity = try castOrThrow(CGPoint.self, value[1])
                let targetContentOffsetValue = try castOrThrow(NSValue.self, value[2])

                guard let rawPointer = targetContentOffsetValue.pointerValue else { throw RxCocoaError.unknown }
                let typedPointer = rawPointer.bindMemory(to: CGPoint.self, capacity: MemoryLayout<CGPoint>.size)

                return (velocity, typedPointer)
        }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewDidEndDragging(_:willDecelerate:)`
    public var didEndDragging: ControlEvent<Bool> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.scrollViewDidEndDragging(_:willDecelerate:))).map { value -> Bool in
            return try castOrThrow(Bool.self, value[1])
        }
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didSelectItemAtIndexPath:)`.
    public var itemSelected: ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didSelectItemAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didSelectItemAtIndexPath:)`.
    public var itemDeselected: ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didDeselectItemAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `ASCollectionDelegate(_:didHighlightItemAt:)`.
    public var itemHighlighted: ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didHighlightItemAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didUnhighlightItemAt:)`.
    public var itemUnhighlighted: ControlEvent<IndexPath> {
        let source = delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didUnhighlightItemAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode:willDisplayItemWith:`.
    public var willDisplayItem: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:willDisplayItemWith:)))
            .map { a in
                return (try castOrThrow(ASCellNode.self, a[1]))
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode:willDisplaySupplementaryElementWith:`.
    public var willDisplaySupplementaryElement: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:willDisplaySupplementaryElementWith:)))
            .map { a in
                return (try castOrThrow(ASCellNode.self, a[1]))
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionView:didEndDisplaying:forItemAt:`.
    public var didEndDisplayingItem: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didEndDisplayingItemWith:)))
            .map { a in
                return (try castOrThrow(ASCellNode.self, a[1]))
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didEndDisplayingSupplementaryElementWith:)`.
    public var didEndDisplayingSupplementaryElement: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:didEndDisplayingSupplementaryElementWith:)))
            .map { a in
                return (try castOrThrow(ASCellNode.self, a[1]))
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:willBeginBatchFetchWith:)`
    public var willBeginBatchFetch: ControlEvent<ASBatchContext> {
        let source: Observable<ASBatchContext> = self.delegate.methodInvoked(#selector(ASCollectionDelegate.collectionNode(_:willBeginBatchFetchWith:)))
            .map { a in
                return try castOrThrow(ASBatchContext.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didSelectItemAtIndexPath:)`.
    ///
    /// It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
    /// or any other data source conforming to `SectionedViewDataSourceType` protocol.
    ///
    /// ```
    ///     collectionNode.rx.modelSelected(MyModel.self)
    ///        .map { ...
    /// ```
    public func modelSelected<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = itemSelected.flatMap { [weak node = self.base as ASCollectionNode] indexPath -> Observable<T> in
            guard let node = node else {
                return Observable.empty()
            }
            
            return Observable.just(try node.rx.model(at: indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /// Reactive wrapper for `delegate` message `collectionNode(_:didSelectItemAtIndexPath:)`.
    ///
    /// It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
    /// or any other data source conforming to `SectionedViewDataSourceType` protocol.
    ///
    /// ```
    ///     collectionNode.rx.modelDeselected(MyModel.self)
    ///        .map { ...
    /// ```
    public func modelDeselected<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = itemDeselected.flatMap { [weak node = self.base as ASCollectionNode] indexPath -> Observable<T> in
            guard let node = node else {
                return Observable.empty()
            }
            
            return Observable.just(try node.rx.model(at: indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /// Synchronous helper method for retrieving a model at indexPath through a reactive data source
    public func model<T>(at indexPath: IndexPath) throws -> T {
        let dataSource: SectionedViewDataSourceType = castOrFatalError(self.dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx.itemsWith*` methods was used.")
        
        let element = try dataSource.model(at: indexPath)
        
        return try castOrThrow(T.self, element)
    }
}

#endif
