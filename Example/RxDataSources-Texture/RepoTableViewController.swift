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
import SnapKit

class RepoTableViewController: UIViewController {
    
    // MARK: Properties
    lazy var tableNode = ASTableNode()
    
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
        super.init(nibName: nil, bundle: nil)
        title = "Table DataSources"
        viewModel.refreshRelay.accept(())
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    // MARK: Set up
    private func setupUI() {
        self.view.addSubview(tableNode.view)
        tableNode.view.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.bottom.equalToSuperview()
            }
            make.leading.trailing.equalToSuperview()
        }
        
        self.tableNode.onDidLoad({ [weak self] _ in
            self?.tableNode.view.separatorStyle = .none
            self?.tableNode.view.alwaysBounceVertical = true
        })
    }
    
    private func bindViewModel() {
        viewModel.sections
            .do(onNext: { [weak self] _ in
                self?.batchContext?.completeBatchFetching(true)
            })
            .bind(to: tableNode.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
        
        tableNode.rx.willBeginBatchFetch
            .subscribe(onNext: { [weak self] batchContext in
                self?.batchContext = batchContext
                self?.viewModel.loadMoreRelay.accept(())
            }).disposed(by: disposeBag)
    }
}

