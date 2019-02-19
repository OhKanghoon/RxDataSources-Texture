//
//  RepoViewModel.swift
//  RxDataSources-Texture_Example
//
//  Created by Kanghoon on 19/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import AsyncDisplayKit
import RxSwift
import RxCocoa

final class RepoViewModel {
    
    let refreshRelay = PublishRelay<Void>()
    let loadMoreRelay = PublishRelay<Void>()
    
    let repos = BehaviorRelay<[Repo]?>(value: nil)
    let since = BehaviorRelay<Int?>(value: nil)
    let sections: Observable<[MainSection]>
    
    let disposeBag = DisposeBag()
    
    init(githubService: GithubServiceProtocol) {
        self.sections = self.repos
            .filterNil()
            .map { [MainSection.repo(repos: $0.map { MainSectionItem.repo($0) })] }
            .asObservable()
        
        repos.map { $0?.last?.id }
            .filterNil()
            .bind(to: since)
            .disposed(by: disposeBag)
        
        refreshRelay
            .flatMap { githubService.repositories(since: nil).catchErrorJustReturn([]) }
            .bind(to: repos)
            .disposed(by: disposeBag)
        
        loadMoreRelay
            .withLatestFrom(since)
            .filterNil()
            .distinctUntilChanged()
            .flatMap { githubService.repositories(since: $0).catchErrorJustReturn([]) }
            .withLatestFrom(repos) { (new, old) -> [Repo] in
                var sequence = old ?? []
                sequence.append(contentsOf: new)
                return sequence
            }.bind(to: repos)
            .disposed(by: disposeBag)
    }
}
