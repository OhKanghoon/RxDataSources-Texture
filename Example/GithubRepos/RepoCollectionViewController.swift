//
//  RepoCollectionViewController.swift
//  GithubRepos
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

class RepoCollectionViewController: ASDKViewController<ASDisplayNode> {

  // MARK: - Properties

  var flowLayout: UICollectionViewFlowLayout = {
    let layout = UICollectionViewFlowLayout()
    layout.scrollDirection = .vertical
    layout.minimumInteritemSpacing = 0
    layout.minimumLineSpacing = 0
    return layout
  }()

  lazy var collectionNode: ASCollectionNode = {
    let node = ASCollectionNode(collectionViewLayout: flowLayout)
    return node
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


  // MARK: Initialization

  init(viewModel: RepoViewModel) {
    self.viewModel = viewModel
    super.init(node: ASDisplayNode())
    self.node.automaticallyManagesSubnodes = true
    self.node.automaticallyRelayoutOnSafeAreaChanges = true
    self.node.layoutSpecBlock = { [weak self] (_, sizeRange) -> ASLayoutSpec in
      return self?.layoutSpecThatFits(sizeRange) ?? ASLayoutSpec()
    }

    self.title = "Collection DataSources"
    self.bindViewModel()
    viewModel.refreshRelay.accept(())
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: - View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.collectionNode.view.alwaysBounceVertical = true
  }


  // MARK: - Binding

  private func bindViewModel() {
    self.collectionNode.rx
      .setDelegate(self)
      .disposed(by: disposeBag)

    self.viewModel.sections
      .do(onNext: { [weak self] _ in
        self?.batchContext?.completeBatchFetching(true)
      })
      .bind(to: collectionNode.rx.items(dataSource: animatedDataSource))
      .disposed(by: disposeBag)

    self.collectionNode.rx.willBeginBatchFetch
      .do(onNext: { [weak self] context in
        self?.batchContext = context
      }).map { _ in return }
      .bind(to: viewModel.loadMoreRelay)
      .disposed(by: disposeBag)
  }


  // MARK: - LayoutSpec

  func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASInsetLayoutSpec(insets: self.node.safeAreaInsets,
                             child: self.collectionNode)
  }
}

extension RepoCollectionViewController: ASCollectionDelegate {
  func shouldBatchFetch(for collectionNode: ASCollectionNode) -> Bool {
    return self.viewModel.since.value != nil
  }
}
