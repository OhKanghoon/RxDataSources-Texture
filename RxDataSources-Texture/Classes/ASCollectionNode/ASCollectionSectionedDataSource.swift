//
//  ASCollectionSectionedDataSource.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)
import Foundation
import AsyncDisplayKit
#if !RX_NO_MODULE
import RxCocoa
#endif
import Differentiator

open class ASCollectionSectionedDataSource<S: SectionModelType>
    : NSObject
    , ASCollectionDataSource
    , SectionedViewDataSourceType {

    public typealias I = S.Item
    public typealias Section = S

    public typealias ConfigureCellBlock = (ASCollectionSectionedDataSource<S>, ASCollectionNode, IndexPath, I) -> ASCellNodeBlock
    public typealias ConfigureSupplementaryNode = (ASCollectionSectionedDataSource<S>, ASCollectionNode, String, IndexPath) -> ASCellNode
    public typealias MoveItem = (ASCollectionSectionedDataSource<S>, _ sourceIndexPath: IndexPath, _ destinationIndexPath:IndexPath) -> Void
    public typealias CanMoveItemWith = (ASCollectionSectionedDataSource<S>, ASCellNode) -> Bool
    
    public init(
        configureCellBlock: @escaping ConfigureCellBlock,
        configureSupplementaryNode: ConfigureSupplementaryNode? = nil,
        moveItem: @escaping MoveItem = { _, _, _ in () },
        canMoveItemWith: @escaping CanMoveItemWith = { _, _ in false }
        ) {
        self.configureCellBlock = configureCellBlock
        self.configureSupplementaryNode = configureSupplementaryNode
        self.moveItem = moveItem
        self.canMoveItemWith = canMoveItemWith
    }
    
    #if DEBUG
    // If data source has already been bound, then mutating it
    // afterwards isn't something desired.
    // This simulates immutability after binding
    var _dataSourceBound: Bool = false
    
    private func ensureNotMutatedAfterBinding() {
        assert(!_dataSourceBound, "Data source is already bound. Please write this line before binding call (`bindTo`, `drive`). Data source must first be completely configured, and then bound after that, otherwise there could be runtime bugs, glitches, or partial malfunctions.")
    }
    
    #endif
    
    // This structure exists because model can be mutable
    // In that case current state value should be preserved.
    // The state that needs to be preserved is ordering of items in section
    // and their relationship with section.
    // If particular item is mutable, that is irrelevant for this logic to function
    // properly.
    public typealias SectionModelSnapshot = SectionModel<S, I>
    
    private var _sectionModels: [SectionModelSnapshot] = []
    
    open var sectionModels: [S] {
        return _sectionModels.map { Section(original: $0.model, items: $0.items) }
    }
    
    open subscript(section: Int) -> S {
        let sectionModel = self._sectionModels[section]
        return S(original: sectionModel.model, items: sectionModel.items)
    }
    
    open subscript(indexPath: IndexPath) -> I {
        get {
            return self._sectionModels[indexPath.section].items[indexPath.item]
        }
        set(item) {
            var section = self._sectionModels[indexPath.section]
            section.items[indexPath.item] = item
            self._sectionModels[indexPath.section] = section
        }
    }
    
    open func model(at indexPath: IndexPath) throws -> Any {
        return self[indexPath]
    }
    
    open func setSections(_ sections: [S]) {
        self._sectionModels = sections.map { SectionModelSnapshot(model: $0, items: $0.items) }
    }
    
    open var configureCellBlock: ConfigureCellBlock {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }

    open var configureSupplementaryNode: ConfigureSupplementaryNode? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    open var moveItem: MoveItem {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    open var canMoveItemWith: ((ASCollectionSectionedDataSource<S>, ASCellNode) -> Bool)? {
        didSet {
            #if DEBUG
            ensureNotMutatedAfterBinding()
            #endif
        }
    }
    
    // ASCollectionDataSource
    
    open func numberOfSections(in collectionNode: ASCollectionNode) -> Int {
        return _sectionModels.count
    }
    
    open func collectionNode(_ collectionNode: ASCollectionNode, numberOfItemsInSection section: Int) -> Int {
        return _sectionModels[section].items.count
    }
    
    open func collectionNode(_ collectionNode: ASCollectionNode, nodeBlockForItemAt indexPath: IndexPath) -> ASCellNodeBlock {
        precondition(indexPath.item < _sectionModels[indexPath.section].items.count)

        return configureCellBlock(self, collectionNode, indexPath, self[indexPath])
    }
    
    open func collectionNode(_ collectionNode: ASCollectionNode, nodeForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> ASCellNode {
        return configureSupplementaryNode!(self, collectionNode, kind, indexPath)
    }
    
    open func collectionNode(_ collectionNode: ASCollectionNode, canMoveItemWith node: ASCellNode) -> Bool {
        guard let canMoveItem = canMoveItemWith?(self, node) else {
            return false
        }
        return canMoveItem
    }
    
    open func collectionNode(_ collectionNode: ASCollectionNode, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        self._sectionModels.moveFromSourceIndexPath(sourceIndexPath, destinationIndexPath: destinationIndexPath)
        self.moveItem(self, sourceIndexPath, destinationIndexPath)
    }
    
    open override func responds(to aSelector: Selector!) -> Bool {
        if aSelector == #selector(ASCollectionDataSource.collectionNode(_:nodeForSupplementaryElementOfKind:at:)) {
            return configureSupplementaryNode != nil
        }
        else {
            return super.responds(to: aSelector)
        }
    }
}
#endif
