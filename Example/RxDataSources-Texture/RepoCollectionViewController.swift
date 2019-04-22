//
//  RepoCollectionViewController.swift
//  RxDataSources-Texture_Example
//
//  Created by Kanghoon on 22/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RxDataSources_Texture
import RxSwift
import RxCocoa
import RxOptional

class RepoCollectionViewController: ASViewController<ASCollectionNode> {
    
    // MARK: Properties
    
    var flowLayout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        return layout
    }()
    
    private let animatedDataSource = RxASCollectionSectionedAnimatedDataSource<MainSection>(
        configureCellBlock: { _, _, _, sectionItem in
            switch sectionItem {
            case .repo(let repoItem):
                return { RepoCellNode(.collection, repo: repoItem) }
            }
    })
    private let dataSource = RxASCollectionSectionedReloadDataSource<MainSection>(
        configureCellBlock: { _, _, _, sectionItem in
            switch sectionItem {
            case .repo(let repoItem):
                return { RepoCellNode(.collection, repo: repoItem) }
            }
    })
    
    var batchContext: ASBatchContext?
    let viewModel: RepoViewModel
    let disposeBag = DisposeBag()
    
    // MARK: Initialize
    init(viewModel: RepoViewModel) {
        self.viewModel = viewModel
        super.init(node: ASCollectionNode(collectionViewLayout: flowLayout))
        self.node.onDidLoad({ [weak self] _ in
            self?.node.view.alwaysBounceVertical = true
        })
        title = "Collection DataSources"
        viewModel.refreshRelay.accept(())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
    }
    
    private func bindViewModel() {
        viewModel.sections
            .do(onNext: { [weak self] _ in
                self?.batchContext?.completeBatchFetching(true)
            })
            .bind(to: node.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
        
        node.rx.willBeginBatchFetch
            .subscribe(onNext: { [weak self] batchContext in
                self?.batchContext = batchContext
                self?.viewModel.loadMoreRelay.accept(())
            }).disposed(by: disposeBag)
    }
}

