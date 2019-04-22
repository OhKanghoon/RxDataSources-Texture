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

class RepoTableViewController: ASViewController<ASDisplayNode> {
    
    // MARK: - Properties
    
    private let animatedDataSource = RxASTableSectionedAnimatedDataSource<MainSection>(
        configureCellBlock: { _, _, _, sectionItem in
            switch sectionItem {
            case .repo(let repoItem):
                return { RepoCellNode(.table, repo: repoItem) }
            }
    })
    
    private let dataSource = RxASTableSectionedReloadDataSource<MainSection>(
        configureCellBlock: { _, _, _, sectionItem in
            switch sectionItem {
            case .repo(let repoItem):
                return { RepoCellNode(.table, repo: repoItem) }
            }
    })
    
    lazy var tableNode: ASTableNode = {
        let node = ASTableNode()
        node.onDidLoad({ [weak self] _ in
            self?.tableNode.view.separatorStyle = .none
            self?.tableNode.view.alwaysBounceVertical = true
        })
        return node
    }()
    
    var batchContext: ASBatchContext?
    let viewModel: RepoViewModel
    let disposeBag = DisposeBag()
    
    // MARK: - Initialization
    
    init(viewModel: RepoViewModel) {
        self.viewModel = viewModel
        super.init(node: ASDisplayNode())
        self.node.automaticallyManagesSubnodes = true
        self.node.automaticallyRelayoutOnSafeAreaChanges = true
        self.node.layoutSpecBlock = { [weak self] (_, sizeRange) -> ASLayoutSpec in
            return self?.layoutSpecThatFits(sizeRange) ?? ASLayoutSpec()
        }
        
        title = "Table DataSources"
        bindViewModel()
        viewModel.refreshRelay.accept(())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Binding
    
    private func bindViewModel() {
        tableNode.rx
            .setDelegate(self)
            .disposed(by: disposeBag)
        
        viewModel.sections
            .do(onNext: { [weak self] _ in
                self?.batchContext?.completeBatchFetching(true)
            })
            .bind(to: tableNode.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
        
        tableNode.rx.willBeginBatchFetch
            .asObservable()
            .do(onNext: { [weak self] context in
                self?.batchContext = context
            }).map { _ in return }
            .bind(to: viewModel.loadMoreRelay)
            .disposed(by: disposeBag)
    }
    
    // MARK: - LayoutSpec
    
    func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
        return ASInsetLayoutSpec(insets: node.safeAreaInsets, child: tableNode)
    }
}

extension RepoTableViewController: ASTableDelegate {
    func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
        return self.viewModel.since.value != nil
    }
}
