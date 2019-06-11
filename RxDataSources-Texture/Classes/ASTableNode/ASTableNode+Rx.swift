//
//  ASTableNode+Rx.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

#if swift(>=4.2)
    public typealias UITableViewCellEditingStyle = UITableViewCell.EditingStyle
#endif

// Items

extension Reactive where Base: ASTableNode {
    
    /**
     Binds sequences of elements to table node rows using a custom reactive data used to perform the transformation.
     This method will retain the data source for as long as the subscription isn't disposed (result `Disposable`
     being disposed).
     In case `source` observable sequence terminates successfully, the data source will present latest element
     until the subscription isn't disposed.
     
     - parameter dataSource: Data source used to transform elements to cell nodes.
     - parameter source: Observable sequence of items.
     - returns: Disposable object that can be used to unbind.
     */
    public func items<
        DataSource: RxASTableDataSourceType & ASTableDataSource,
        O: ObservableType>
        (dataSource: DataSource)
        -> (_ source: O)
        -> Disposable
        where DataSource.Element == O.E {
            return { source in
                // Strong reference is needed because data source is in use until result subscription is disposed
                return source.subscribeProxyDataSource(ofObject: self.base, dataSource: dataSource as ASTableDataSource, retainDataSource: true) { [weak tableNode = self.base] (_: RxASTableDataSourceProxy, event) -> Void in
                    guard let tableNode = tableNode else {
                        return
                    }
                    dataSource.tableNode(tableNode, observedEvent: event)
                }
            }
    }
    
}

extension Reactive where Base: ASTableNode {
    
    /**
     Reactive wrapper for `delegate`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var delegate: DelegateProxy<ASTableNode, ASTableDelegate> {
        return RxASTableDelegateProxy.proxy(for: base)
    }
    
    /**
     Reactive wrapper for `dataSource`.
     
     For more information take a look at `DelegateProxyType` protocol documentation.
     */
    public var dataSource: DelegateProxy<ASTableNode, ASTableDataSource> {
        return RxASTableDataSourceProxy.proxy(for: base)
    }
    
    /**
     Installs data source as forwarding delegate on `rx.dataSource`.
     Data source won't be retained.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter dataSource: Data source object.
     - returns: Disposable object that can be used to unbind the data source.
     */
    public func setDataSource(_ dataSource: ASTableDataSource)
        -> Disposable {
            return RxASTableDataSourceProxy.installForwardDelegate(dataSource, retainDelegate: false, onProxyForObject: self.base)
    }
    
    /**
     Installs delegate as forwarding delegate on `rx.delegate`.
     Data source won't be retained.
     
     It enables using normal delegate mechanism with reactive delegate mechanism.
     
     - parameter delegate: Delegate object
     - returns: Disposable object that can be used to unbind the delegate.
     */
    public func setDelegate(_ delegate: ASTableDelegate)
        -> Disposable {
            return RxASTableDelegateProxy.installForwardDelegate(delegate, retainDelegate: false, onProxyForObject: self.base)
    }
    
    /// Reactive wrapper for `contentOffset`.
    public var contentOffset: ControlProperty<CGPoint> {
        let proxy = RxASTableDelegateProxy.proxy(for: base)

        let bindingObserver = Binder(self.base) { tableNode, contentOffset in
            tableNode.contentOffset = contentOffset
        }

        return ControlProperty(values: proxy.contentOffsetBehaviorSubject, valueSink: bindingObserver)
    }

    /// Reactive wrapper for delegate method `scrollViewDidScroll`
    public var didScroll: ControlEvent<Void> {
        let source = RxASTableDelegateProxy.proxy(for: base).contentOffsetPublishSubject
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewWillBeginDecelerating`
    public var willBeginDecelerating: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(ASTableDelegate.scrollViewWillBeginDecelerating(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewDidEndDecelerating`
    public var didEndDecelerating: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(ASTableDelegate.scrollViewDidEndDecelerating(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewWillBeginDragging`
    public var willBeginDragging: ControlEvent<Void> {
        let source = delegate.methodInvoked(#selector(ASTableDelegate.scrollViewWillBeginDragging(_:))).map { _ in }
        return ControlEvent(events: source)
    }

    /// Reactive wrapper for delegate method `scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)`
    public var willEndDragging: ControlEvent<WillEndDraggingEvent> {
        let source = delegate.methodInvoked(#selector(ASTableDelegate.scrollViewWillEndDragging(_:withVelocity:targetContentOffset:)))
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
        let source = delegate.methodInvoked(#selector(ASTableDelegate.scrollViewDidEndDragging(_:willDecelerate:))).map { value -> Bool in
            return try castOrThrow(Bool.self, value[1])
        }
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:didSelectRowAtIndexPath:`.
     */
    public var itemSelected: ControlEvent<IndexPath> {
        let source = self.delegate.methodInvoked(#selector(ASTableDelegate.tableNode(_:didSelectRowAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:didDeselectRowAtIndexPath:`.
     */
    public var itemDeselected: ControlEvent<IndexPath> {
        let source = self.delegate.methodInvoked(#selector(ASTableDelegate.tableNode(_:didDeselectRowAt:)))
            .map { a in
                return try castOrThrow(IndexPath.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableView:commitEditingStyle:forRowAtIndexPath:`.
     */
    public var itemInserted: ControlEvent<IndexPath> {
        let source = self.dataSource.methodInvoked(#selector(ASTableDataSource.tableView(_:commit:forRowAt:)))
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (try castOrThrow(NSNumber.self, a[1])).intValue) == .insert
            }
            .map { a in
                return (try castOrThrow(IndexPath.self, a[2]))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableView:commitEditingStyle:forRowAtIndexPath:`.
     */
    public var itemDeleted: ControlEvent<IndexPath> {
        let source = self.dataSource.methodInvoked(#selector(ASTableDataSource.tableView(_:commit:forRowAt:)))
            .filter { a in
                return UITableViewCellEditingStyle(rawValue: (try castOrThrow(NSNumber.self, a[1])).intValue) == .delete
            }
            .map { a in
                return try castOrThrow(IndexPath.self, a[2])
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableView:moveRowAtIndexPath:toIndexPath:`.
     */
    public var itemMoved: ControlEvent<ItemMovedEvent> {
        let source: Observable<ItemMovedEvent> = self.dataSource.methodInvoked(#selector(ASTableDataSource.tableView(_:moveRowAt:to:)))
            .map { a in
                return (try castOrThrow(IndexPath.self, a[1]), try castOrThrow(IndexPath.self, a[2]))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:willDisplayCell:forRowAtIndexPath:`.
     */
    public var willDisplayCell: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASTableDelegate.tableNode(_:willDisplayRowWith:)))
            .map { a in
                return try castOrThrow(ASCellNode.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:didEndDisplayingCell:forRowAtIndexPath:`.
     */
    public var didEndDisplayingCell: ControlEvent<ASCellNode> {
        let source: Observable<ASCellNode> = self.delegate.methodInvoked(#selector(ASTableDelegate.tableNode(_:didEndDisplayingRowWith:)))
            .map { a in
                return try castOrThrow(ASCellNode.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:willBeginBatchFetchWith`
     */
    public var willBeginBatchFetch: ControlEvent<ASBatchContext> {
        let source: Observable<ASBatchContext> = self.delegate.methodInvoked(#selector(ASTableDelegate.tableNode(_:willBeginBatchFetchWith:)))
            .map { a in
                return try castOrThrow(ASBatchContext.self, a[1])
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:didSelectRowAtIndexPath:`.
     
     It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
     or any other data source conforming to `SectionedViewDataSourceType` protocol.
     
     ```
     tableNode.rx.modelSelected(MyModel.self)
     .map { ...
     ```
     */
    public func modelSelected<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = self.itemSelected.flatMap { [weak view = self.base as ASTableNode] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }
            
            return Observable.just(try view.rx.model(at: indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:didDeselectRowAtIndexPath:`.
     
     It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
     or any other data source conforming to `SectionedViewDataSourceType` protocol.
     
     ```
     tableNode.rx.modelDeselected(MyModel.self)
     .map { ...
     ```
     */
    public func modelDeselected<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = self.itemDeselected.flatMap { [weak view = self.base as ASTableNode] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }
            
            return Observable.just(try view.rx.model(at: indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Reactive wrapper for `delegate` message `tableNode:commitEditingStyle:forRowAtIndexPath:`.
     
     It can be only used when one of the `rx.itemsWith*` methods is used to bind observable sequence,
     or any other data source conforming to `SectionedViewDataSourceType` protocol.
     
     ```
     tableNode.rx.modelDeleted(MyModel.self)
     .map { ...
     ```
     */
    public func modelDeleted<T>(_ modelType: T.Type) -> ControlEvent<T> {
        let source: Observable<T> = self.itemDeleted.flatMap { [weak view = self.base as ASTableNode] indexPath -> Observable<T> in
            guard let view = view else {
                return Observable.empty()
            }
            
            return Observable.just(try view.rx.model(at: indexPath))
        }
        
        return ControlEvent(events: source)
    }
    
    /**
     Synchronous helper method for retrieving a model at indexPath through a reactive data source.
     */
    public func model<T>(at indexPath: IndexPath) throws -> T {
        let dataSource: SectionedViewDataSourceType = castOrFatalError(self.dataSource.forwardToDelegate(), message: "This method only works in case one of the `rx.items*` methods was used.")
        
        let element = try dataSource.model(at: indexPath)
        
        return castOrFatalError(element)
    }
}

#endif
