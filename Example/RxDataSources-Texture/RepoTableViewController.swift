//
//  RepoTableViewController.swift
//  RxDataSources-Texture_Example
//
//  Created by Kanghoon on 19/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RxDataSources_Texture
import RxSwift
import RxCocoa
import RxOptional

class RepoTableViewController: ASViewController<ASTableNode> {
    
    private let animatedDataSource = RxASTableSectionedAnimatedDataSource<MainSection>(
        configureCell: { _, _, _, sectionItem in
            switch sectionItem {
            case .repo(let repoItem):
                return RepoCellNode(.table, repo: repoItem)
            }
    })
    private let dataSource = RxASTableSectionedReloadDataSource<MainSection>(
        configureCell: { _, _, _, sectionItem in
            switch sectionItem {
            case .repo(let repoItem):
                return RepoCellNode(.table, repo: repoItem)
            }
    })
    
    var batchContext: ASBatchContext?
    let viewModel: RepoViewModel
    let disposeBag = DisposeBag()
    
    // MARK: Initialize
    init(viewModel: RepoViewModel) {
        self.viewModel = viewModel
        super.init(node: ASTableNode())
        
        self.node.onDidLoad({ [weak self] _ in
            self?.node.view.separatorStyle = .none
            self?.node.view.alwaysBounceVertical = true
        })
        
        title = "Table DataSources"
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
