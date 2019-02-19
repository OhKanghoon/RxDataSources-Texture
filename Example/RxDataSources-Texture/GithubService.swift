//
//  GithubService.swift
//  RxDataSources-Texture_Example
//
//  Created by Kanghoon on 19/02/2019.
//  Copyright © 2019 CocoaPods. All rights reserved.
//

import Foundation
import RxSwift
import RxAlamofire

protocol GithubServiceProtocol {
    func repositories(since: Int?) -> Single<[Repo]>
}

final class GithubService: GithubServiceProtocol {
    
    init() {}
    
    func repositories(since: Int?) -> Single<[Repo]> {
        return RxAlamofire.request(.get,
                                   "https://api.github.com/repositories",
                                   parameters: since.map { ["since": $0] })
            .validate(statusCode: 200..<300)
            .responseData()
            .debug()
            .map { $0.1 }
            .flatMap { data -> Observable<[Repo]> in
                let decoder = JSONDecoder()
                let object = try decoder.decode([Repo].self, from: data)
                return Observable.just(object)
            }.asSingle()
    }
}
