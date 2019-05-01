//
//  RxASCollectionSectionedReloadDataSource.swift
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

open class RxASCollectionSectionedReloadDataSource<S: SectionModelType>
    : ASCollectionSectionedDataSource<S>
    , RxASCollectionDataSourceType {
    
    public typealias Element = [S]
    
    open func collectionNode(_ collectionNode: ASCollectionNode, observedEvent: Event<[S]>) {
        Binder(self) { dataSource, element in
            #if DEBUG
                dataSource._dataSourceBound = true
            #endif
            dataSource.setSections(element)
            collectionNode.reloadData()
            collectionNode.collectionViewLayout.invalidateLayout()
        }.on(observedEvent)
    }
}
#endif
