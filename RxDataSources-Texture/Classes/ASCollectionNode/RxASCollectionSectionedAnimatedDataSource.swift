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
        configureCellBlock: @escaping ConfigureCellBlock,
        configureSupplementaryNode: ConfigureSupplementaryNode? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemWith: @escaping CanMoveItemWith = { _, _ in false }
        ) {
        self.animationConfiguration = animationConfiguration
        self.decideNodeTransition = decideNodeTransition
        super.init(
            configureCellBlock: configureCellBlock,
            configureSupplementaryNode: configureSupplementaryNode,
            moveItem: moveItem,
            canMoveItemWith: canMoveItemWith
        )
    }
    
    // there is no longer limitation to load initial sections with reloadData
    // but it is kept as a feature everyone got used to
    var dataSet = false
    
    open func collectionNode(_ collectionNode: ASCollectionNode, observedEvent: Event<Element>) {
        Binder(self) { dataSource, newSections in
            #if DEBUG
            dataSource._dataSourceBound = true
            #endif
            if !dataSource.dataSet {
                dataSource.dataSet = true
                dataSource.setSections(newSections)
                collectionNode.reloadData()
            }
            else {
                let oldSections = dataSource.sectionModels
                do {
                    let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                    
                    switch dataSource.decideNodeTransition(dataSource, collectionNode, differences) {
                    case .animated:
                        // each difference must be run in a separate 'performBatchUpdates', otherwise it crashes.
                        // this is a limitation of Diff tool
                        for difference in differences {
                            let updateBlock = {
                                // sections must be set within updateBlock in 'performBatchUpdates'
                                dataSource.setSections(difference.finalSections)
                                
                                collectionNode.batchUpdates(difference, animationConfiguration: dataSource.animationConfiguration)
                            }
                            collectionNode.performBatch(animated: dataSource.animationConfiguration.animated,
                                                        updates: updateBlock,
                                                        completion: nil)
                        }
                        
                    case .reload:
                        dataSource.setSections(newSections)
                        collectionNode.reloadData()
                        return
                    }
                }
                catch let e {
                    rxDebugFatalError(e)
                    dataSource.setSections(newSections)
                    collectionNode.reloadData()
                }
            }
        }.on(observedEvent)
    }
}
#endif
