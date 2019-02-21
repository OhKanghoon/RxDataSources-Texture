//
//  RxASCollectionSectionedAnimatedDataSource.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 21/02/2019.
//

#if os(iOS) || os(tvOS)
import Foundation
import AsyncDisplayKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
import Differentiator

open class RxASCollectionSectionedAnimatedDataSource<S: AnimatableSectionModelType>
    : ASCollectionSectionedDataSource<S>
    , RxASCollectionDataSourceType {
    
    public typealias Element = [S]
    public typealias DecideNodeTransition = (ASCollectionSectionedDataSource<S>, ASCollectionNode, [Changeset<S>]) -> NodeTransition
    
    /// Animation configuration for data source
    public var animationConfiguration: AnimationConfiguration
    
    /// Calculates view transition depending on type of changes
    public var decideNodeTransition: DecideNodeTransition
    
    public init(
        animationConfiguration: AnimationConfiguration = AnimationConfiguration(),
        decideNodeTransition: @escaping DecideNodeTransition = { _, _, _ in .animated },
        configureCell: @escaping ConfigureCell,
        configureSupplementaryNode: ConfigureSupplementaryNode? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemWith: @escaping CanMoveItemWith = { _, _ in false }
        ) {
        self.animationConfiguration = animationConfiguration
        self.decideNodeTransition = decideNodeTransition
        super.init(
            configureCell: configureCell,
            configureSupplementaryNode: configureSupplementaryNode,
            moveItem: moveItem,
            canMoveItemWith: canMoveItemWith
        )
    }
    
    // For some inexplicable reason, when doing animated updates first time
    // it crashes. Still need to figure out that one.
    var dataSet = false
    
    private let disposeBag = DisposeBag()
    
    // This subject and throttle are here
    // because collection node has problems processing animated updates fast.
    // This should somewhat help to alleviate the problem.
    private let partialUpdateEvent = PublishSubject<(ASCollectionNode, Event<Element>)>()
    
    open func collectionNode(_ collectionNode: ASCollectionNode, throttledObservedEvent event: Event<Element>) {
        Binder(self) { dataSource, newSections in
            let oldSections = dataSource.sectionModels
            do {
                // if view is not in view hierarchy, performing batch updates will crash the app
                if collectionNode.view.window == nil {
                    dataSource.setSections(newSections)
                    collectionNode.reloadData()
                    return
                }
                let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                
                switch self.decideNodeTransition(self, collectionNode, differences) {
                case .animated:
                    for difference in differences {
                        dataSource.setSections(difference.finalSections)
                        
                        collectionNode.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                    }
                case .reload:
                    self.setSections(newSections)
                    collectionNode.reloadData()
                }
            }
            catch let e {
                #if DEBUG
                print("Error while binding data animated: \(e)\nFallback to normal `reloadData` behavior.")
                rxDebugFatalError(e)
                #endif
                self.setSections(newSections)
                collectionNode.reloadData()
            }
        }.on(event)
    }
    
    open func collectionNode(_ collectionNode: ASCollectionNode, observedEvent: Event<Element>) {
        Binder(self) { dataSource, newSections in
            #if DEBUG
            self._dataSourceBound = true
            #endif
            if !self.dataSet {
                self.dataSet = true
                dataSource.setSections(newSections)
                collectionNode.reloadData()
            }
            else {
                let element = (collectionNode, observedEvent)
                dataSource.partialUpdateEvent.on(.next(element))
            }
        }.on(observedEvent)
    }
}
#endif
