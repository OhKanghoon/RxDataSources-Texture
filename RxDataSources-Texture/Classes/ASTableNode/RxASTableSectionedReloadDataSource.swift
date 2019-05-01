//
//  RxASTableSectionedReloadDataSource.swift
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

open class RxASTableSectionedReloadDataSource<S: SectionModelType>
    : ASTableSectionedDataSource<S>
    , RxASTableDataSourceType {
    public typealias Element = [S]
    
    open func tableNode(_ tableNode: ASTableNode, observedEvent: Event<Element>) {
        Binder(self) { dataSource, element in
            #if DEBUG
            dataSource._dataSourceBound = true
            #endif
            dataSource.setSections(element)
            tableNode.reloadData()
        }.on(observedEvent)
    }
}
#endif
