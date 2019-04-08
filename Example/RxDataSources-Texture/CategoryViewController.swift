//
//  CategoryViewController.swift
//  RxDataSources-Texture_Example
//
//  Created by Kanghoon on 22/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import UIKit
import AsyncDisplayKit
import RxSwift
import RxCocoa
import RxOptional

final class CategoryViewController: ASViewController<ASTableNode> {
    
    enum Item: Int, CaseIterable {
        case table
        case collection
        
        var title: String {
            switch self {
            case .table: return "ASTableNode Example"
            case .collection: return "ASCollectionNode Example"
            }
        }
    }
    
    // MARK: Initialization
    init() {
        super.init(node: ASTableNode())
        node.delegate = self
        node.dataSource = self
        self.node.onDidLoad({ [weak self] _ in
            self?.node.view.alwaysBounceVertical = true
        })
        title = "Categories"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension CategoryViewController: ASTableDataSource {
    func tableNode(_ tableNode: ASTableNode, numberOfRowsInSection section: Int) -> Int {
        return Item.allCases.count
    }
    
    func tableNode(_ tableNode: ASTableNode, nodeForRowAt indexPath: IndexPath) -> ASCellNode {
        guard let item = Item(rawValue: indexPath.row) else { return ASCellNode() }
        let cell = ASTextCellNode()
        cell.selectionStyle = .none
        cell.text = item.title
        return cell
    }
}


extension CategoryViewController: ASTableDelegate {
    func tableNode(_ tableNode: ASTableNode, didSelectRowAt indexPath: IndexPath) {
        guard let item = Item(rawValue: indexPath.row) else { return }
        let vc: UIViewController
        let viewModel = RepoViewModel(githubService: GithubService())
        switch item {
        case .table:
            vc = RepoTableViewController(viewModel: viewModel)
        case .collection:
            vc = RepoCollectionViewController(viewModel: viewModel)
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
