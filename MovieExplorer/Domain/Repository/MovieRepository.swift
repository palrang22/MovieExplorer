//
//  MovieRepository.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import RxSwift


protocol MovieRepository {
    func fetchData() -> Single<[MovieEntity]>
}
