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
        configureCell: @escaping ConfigureCell,
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
            configureCell: configureCell,
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
        configureCell: @escaping ConfigureCell,
        titleForHeaderInSection: @escaping  TitleForHeaderInSection = { _, _ in nil },
        titleForFooterInSection: @escaping TitleForFooterInSection = { _, _ in nil },
        canEditRowAtIndexPath: @escaping CanEditRowAtIndexPath = { _, _ in false },
        canMoveRowAtIndexPath: @escaping CanMoveRowAtIndexPath = { _, _ in false }
        ) {
        self.animationConfiguration = animationConfiguration
        self.decideNodeTransition = decideNodeTransition
        super.init(
            configureCell: configureCell,
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
            self._dataSourceBound = true
            #endif
            if !self.dataSet {
                self.dataSet = true
                dataSource.setSections(newSections)
                tableNode.reloadData()
            }
            else {
                DispatchQueue.main.async {
                    let oldSections = dataSource.sectionModels
                    do {
                        let differences = try Diff.differencesForSectionedView(initialSections: oldSections, finalSections: newSections)
                        
                        switch self.decideNodeTransition(self, tableNode, differences) {
                        case .animated:
                            for difference in differences {
                                dataSource.setSections(difference.finalSections)
                                
                                tableNode.performBatchUpdates(difference, animationConfiguration: self.animationConfiguration)
                            }
                        case .reload:
                            self.setSections(newSections)
                            tableNode.reloadData()
                            return
                        }
                    }
                    catch let e {
                        rxDebugFatalError(e)
                        self.setSections(newSections)
                        tableNode.reloadData()
                    }
                }
            }
            }.on(observedEvent)
    }
}
#endif
