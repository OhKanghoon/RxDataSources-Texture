//
//  RepoTableViewController.swift
//  GithubRepos
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

  let tableNode = ASTableNode()

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

    self.title = "Table DataSources"
    self.bindViewModel()
    viewModel.refreshRelay.accept(())
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }


  // MARK: - View Life Cycle

  override func viewDidLoad() {
    super.viewDidLoad()
    self.tableNode.view.separatorStyle = .none
    self.tableNode.view.alwaysBounceVertical = true
  }


  // MARK: - Binding

  private func bindViewModel() {
    self.tableNode.rx
      .setDelegate(self)
      .disposed(by: disposeBag)

    self.viewModel.sections
      .do(onNext: { [weak self] _ in
        self?.batchContext?.completeBatchFetching(true)
      })
      .bind(to: tableNode.rx.items(dataSource: animatedDataSource))
      .disposed(by: disposeBag)

    self.tableNode.rx.willBeginBatchFetch
      .asObservable()
      .do(onNext: { [weak self] context in
        self?.batchContext = context
      }).map { _ in return }
      .bind(to: viewModel.loadMoreRelay)
      .disposed(by: disposeBag)
  }


  // MARK: - LayoutSpec

  func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    return ASInsetLayoutSpec(insets: self.node.safeAreaInsets, child: self.tableNode)
  }
}

extension RepoTableViewController: ASTableDelegate {
  func shouldBatchFetch(for tableNode: ASTableNode) -> Bool {
    return self.viewModel.since.value != nil
  }
}
