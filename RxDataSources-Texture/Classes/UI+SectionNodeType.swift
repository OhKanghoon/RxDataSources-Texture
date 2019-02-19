//
//  UI+SectionNodeType.swift
//  RxTextureDataSources
//
//  Created by Kanghoon on 2018. 12. 18..
//

#if os(iOS) || os(tvOS)
import Foundation
import AsyncDisplayKit
import Differentiator

#if swift(>=4.2)
public typealias UITableViewRowAnimation = UITableView.RowAnimation
#endif

func indexSet(_ values: [Int]) -> IndexSet {
    let indexSet = NSMutableIndexSet()
    for i in values {
        indexSet.add(i)
    }
    return indexSet as IndexSet
}

extension ASTableNode: SectionedNodeType {
    
    public func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.insertRows(at: paths, with: animationStyle)
    }
    
    public func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.deleteRows(at: paths, with: animationStyle)
    }
    
    public func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath) {
        self.moveRow(at: from, to: to)
    }
    
    public func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation) {
        self.reloadRows(at: paths, with: animationStyle)
    }
    
    public func insertSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.insertSections(indexSet(sections), with: animationStyle)
    }
    
    public func deleteSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.deleteSections(indexSet(sections), with: animationStyle)
    }
    
    public func moveSection(_ from: Int, to: Int) {
        self.moveSection(from, toSection: to)
    }
    
    public func reloadSections(_ sections: [Int], animationStyle: UITableViewRowAnimation) {
        self.reloadSections(indexSet(sections), with: animationStyle)
    }
    
    public func performBatchUpdates<S>(_ changes: Changeset<S>, animationConfiguration: AnimationConfiguration) {
        self.performBatch(animated: true, updates: {
            _performBatchUpdates(self, changes: changes, animationConfiguration: animationConfiguration)
        }, completion: nil)
    }
}

public protocol SectionedNodeType {
    func insertItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation)
    func deleteItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation)
    func moveItemAtIndexPath(_ from: IndexPath, to: IndexPath)
    func reloadItemsAtIndexPaths(_ paths: [IndexPath], animationStyle: UITableViewRowAnimation)
    
    func insertSections(_ sections: [Int], animationStyle: UITableViewRowAnimation)
    func deleteSections(_ sections: [Int], animationStyle: UITableViewRowAnimation)
    func moveSection(_ from: Int, to: Int)
    func reloadSections(_ sections: [Int], animationStyle: UITableViewRowAnimation)
    
    func performBatchUpdates<S>(_ changes: Changeset<S>, animationConfiguration: AnimationConfiguration)
}

func _performBatchUpdates<N: SectionedNodeType, S>(_ node: N, changes: Changeset<S>, animationConfiguration: AnimationConfiguration) {
    typealias I = S.Item
    
    node.deleteSections(changes.deletedSections, animationStyle: animationConfiguration.deleteAnimation)
    // Updated sections doesn't mean reload entire section, somebody needs to update the section view manually
    // otherwise all cells will be reloaded for nothing.
    //view.reloadSections(changes.updatedSections, animationStyle: rowAnimation)
    node.insertSections(changes.insertedSections, animationStyle: animationConfiguration.insertAnimation)
    for (from, to) in changes.movedSections {
        node.moveSection(from, to: to)
    }
    
    node.deleteItemsAtIndexPaths(
        changes.deletedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.deleteAnimation
    )
    node.insertItemsAtIndexPaths(
        changes.insertedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.insertAnimation
    )
    node.reloadItemsAtIndexPaths(
        changes.updatedItems.map { IndexPath(item: $0.itemIndex, section: $0.sectionIndex) },
        animationStyle: animationConfiguration.reloadAnimation
    )
    
    for (from, to) in changes.movedItems {
        node.moveItemAtIndexPath(
            IndexPath(item: from.itemIndex, section: from.sectionIndex),
            to: IndexPath(item: to.itemIndex, section: to.sectionIndex)
        )
    }
}
#endif
