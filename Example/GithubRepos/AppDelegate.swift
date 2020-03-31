//
//  AppDelegate.swift
//  GithubRepos
//
//  Created by ohkanghoon on 2020/03/31.
//  Copyright © 2020 kanghoon. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.backgroundColor = .white
    window?.makeKeyAndVisible()

    let viewController = CategoryViewController()

    let navigationController = UINavigationController(rootViewController: viewController)
    window?.rootViewController = navigationController
    return true
  }
}

