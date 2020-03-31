//
//  RepoCellNode.swift
//  GithubRepos
//
//  Created by Kanghoon on 19/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit

final class RepoCellNode: ASCellNode {

  enum Const {
    static let imageSize: CGSize = .init(width: 60, height: 60)
    static let spacing: CGFloat = 8
    static let placeholderColor: UIColor = .init(
      red: 233.0 / 255.0,
      green: 237.0 / 255.0,
      blue: 240.0 / 255.0,
      alpha: 1.0
    )
  }

  enum ViewType {
    case table
    case collection
  }

  let imageNode: ASNetworkImageNode = {
    let node = ASNetworkImageNode()
    node.style.preferredSize = Const.imageSize
    node.placeholderFadeDuration = 0.3
    node.placeholderColor = Const.placeholderColor
    return node
  }()

  let titleNode: ASTextNode = {
    let node = ASTextNode()
    node.maximumNumberOfLines = 2
    node.style.flexShrink = 1.0
    return node
  }()

  let type: ViewType

  init(_ type: ViewType, repo: Repo) {
    self.type = type
    super.init()
    self.automaticallyManagesSubnodes = true
    self.backgroundColor = .white
    self.selectionStyle = .none

    imageNode.url = URL(string: repo.owner.avatarURL)
    titleNode.attributedText = NSAttributedString(
      string: repo.fullName,
      attributes: [.font: UIFont.systemFont(ofSize: 13),
                   .foregroundColor: UIColor.black]
    )
  }

  override func layoutSpecThatFits(_ constrainedSize: ASSizeRange) -> ASLayoutSpec {
    let contentStackSpec = ASStackLayoutSpec(
      direction: .horizontal,
      spacing: Const.spacing,
      justifyContent: .start,
      alignItems: .center,
      children: [
        imageNode,
        titleNode
      ]
    )
    switch type {
    case .collection:
      contentStackSpec.style.preferredLayoutSize.width = ASDimensionMake(constrainedSize.max.width / 2 - 1)
    default: break
    }

    return ASInsetLayoutSpec(insets: .zero, child: contentStackSpec)
  }
}
