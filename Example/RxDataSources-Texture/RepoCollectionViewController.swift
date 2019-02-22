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
import SnapKit

class RepoCollectionViewController: UIViewController {
    
    // MARK: Properties
    
    lazy var collectionNode: ASCollectionNode = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .vertical
        flowLayout.minimumLineSpacing = 0
        return ASCollectionNode(collectionViewLayout: flowLayout)
    }()
    
    private let animatedDataSource = RxASCollectionSectionedAnimatedDataSource<MainSection>(
        configureCell: { _, _, _, sectionItem in
            switch sectionItem {
            case .repo(let repoItem):
                return RepoCellNode(.collection, repo: repoItem)
            }
    })
    private let dataSource = RxASCollectionSectionedReloadDataSource<MainSection>(
        configureCell: { _, _, _, sectionItem in
            switch sectionItem {
            case .repo(let repoItem):
                return RepoCellNode(.collection, repo: repoItem)
            }
    })
    
    var batchContext: ASBatchContext?
    let viewModel: RepoViewModel
    let disposeBag = DisposeBag()
    
    // MARK: Initialize
    init(viewModel: RepoViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Collection DataSources"
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
        self.view.addSubview(collectionNode.view)
        collectionNode.view.snp.makeConstraints { make in
            if #available(iOS 11.0, *) {
                make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.top.bottom.equalToSuperview()
            }
            make.leading.trailing.equalToSuperview()
        }
        
        self.collectionNode.onDidLoad({ [weak self] _ in
            self?.collectionNode.view.alwaysBounceVertical = true
        })
    }
    
    private func bindViewModel() {
        viewModel.sections
            .do(onNext: { [weak self] _ in
                self?.batchContext?.completeBatchFetching(true)
            })
            .bind(to: collectionNode.rx.items(dataSource: animatedDataSource))
            .disposed(by: disposeBag)
        
        collectionNode.rx.willBeginBatchFetch
            .subscribe(onNext: { [weak self] batchContext in
                self?.batchContext = batchContext
                self?.viewModel.loadMoreRelay.accept(())
            }).disposed(by: disposeBag)
    }
}

