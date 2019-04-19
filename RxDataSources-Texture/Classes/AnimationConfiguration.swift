//
//  AnimationConfiguration.swift
//  RxDataSources-Texture
//
//  Created by Kanghoon on 19/02/2019.
//

#if os(iOS) || os(tvOS)
import Foundation
import UIKit

/**
 Exposes custom animation styles for insertion, deletion and reloading behavior.
 */
public struct AnimationConfiguration {
    public let animated: Bool
    public let insertAnimation: UITableViewRowAnimation
    public let reloadAnimation: UITableViewRowAnimation
    public let deleteAnimation: UITableViewRowAnimation
    
    public init(animated: Bool = true,
                insertAnimation: UITableViewRowAnimation = .automatic,
                reloadAnimation: UITableViewRowAnimation = .automatic,
                deleteAnimation: UITableViewRowAnimation = .automatic) {
        self.animated = animated
        self.insertAnimation = insertAnimation
        self.reloadAnimation = reloadAnimation
        self.deleteAnimation = deleteAnimation
    }
}
#endif
