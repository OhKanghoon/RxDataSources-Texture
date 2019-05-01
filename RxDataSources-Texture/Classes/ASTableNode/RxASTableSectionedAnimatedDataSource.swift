//
//  RxASTableSectionedAnimatedDataSource.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)
import Foundation
import AsyncDisplayKit
#if !RX_NO_MODULE
import RxSwift
import RxCocoa
#endif
import Differentiator

open class RxASTableSectionedAnimatedDataSource<S: AnimatableSectionModelType>
    : ASTableSectionedDataSource<S>
    , RxASTableDataSourceType {
    
    public typealias Element = [S]
    public typealias DecideNodeTransition = (ASTableSectionedDataSource<S>, ASTableNode, [Changeset<S>]) -> NodeTransition
    
    /// Animation configuration for data source
    public var animationConfiguration: AnimationConfiguration
    
    /// Calculates view transition depending on type of changes
    public var decideNodeTransition: DecideNodeTransition
    private var dataSet = false
    
    #if os(iOS)
    public init(
        animationConfiguration: AnimationConfiguration = AnimationConfiguration(),
        decideNodeTransition: @escaping DecideNodeTransition = { _, _, _ in .animated },
        configureCellBlock: @escaping ConfigureCellBlock,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false },
        sectionIndexTitles: @escaping SectionIndexTitles = { _ in nil },
        sectionForSectionIndexTitle: @escaping SectionForSectionIndexTitle = { _, _, index in index }
        ) {
        self.animationConfiguration = animationConfiguration
        self.decideNodeTransition = decideNodeTransition
        super.init(
            configureCellBlock: configureCellBlock,
            titleForHeaderInSection: titleForHeaderInSection,
            titleForFooterInSection: titleForFooterInSection,
            canEditRowAtIndexPath: canEditRowAtIndexPath,
            canMoveRowAtIndexPath: canMoveRowAtIndexPath,
            sectionIndexTitles: sectionIndexTitles,
            sectionForSectionIndexTitle: sectionForSectionIndexTitle
        )
    }
    #else
    public init(
        animationConfiguration: AnimationConfiguration = AnimationConfiguration(),
        decideNodeTransition: @escaping DecideNodeTransition = { _, _, _ in .animated },
        configureCellBlock: @escaping ConfigureCellBlock,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false }
        ) {
        self.animationConfiguration = animationConfiguration
        self.decideNodeTransition = decideNodeTransition
        super.init(
            configureCellBlock: configureCellBlock,
            titleForHeaderInSection: titleForHeaderInSection,
            titleForFooterInSection: titleForFooterInSection,
            canEditRowAtIndexPath: canEditRowAtIndexPath,
            canMoveRowAtIndexPath: canMoveRowAtIndexPath
        )
    }
    #endif
    
    public func tableNode(_ tableNode: ASTableNode, observedEvent: Event<[S]>) {
        Binder(self) { dataSource, newSections in
            #if DEBUG
            dataSource._dataSourceBound = true
            #endif
            if !dataSource.dataSet {
                dataSource.dataSet = true
                dataSource.setSections(newSections)
                tableNode.reloadData()
            }
            else {
                let oldSections = dataSource.sectionModels
                do {
                    let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                    
                    switch dataSource.decideNodeTransition(dataSource, tableNode, differences) {
                    case .animated:
                        for difference in differences {
                            let updateBlock = {
                                // sections must be set within updateBlock in 'performBatchUpdates'
                                dataSource.setSections(difference.finalSections)
                                tableNode.batchUpdates(difference, animationConfiguration: dataSource.animationConfiguration)
                            }
                            tableNode.performBatch(animated: dataSource.animationConfiguration.animated,
                                                   updates: updateBlock,
                                                   completion: nil)
                        }
                    case .reload:
                        dataSource.setSections(newSections)
                        tableNode.reloadData()
                        return
                    }
                }
                catch let e {
                    rxDebugFatalError(e)
                    dataSource.setSections(newSections)
                    tableNode.reloadData()
                }
            }
            }.on(observedEvent)
    }
}
#endif
