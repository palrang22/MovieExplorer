//
//  JsonLoader.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import Foundation

import RxSwift
import Then


final class JsonLoader {
    private let decoder = JSONDecoder().then {
        $0.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    func load<T:Decodable>(fileName: String) -> Single<T> {
        return Single.create { single in
            guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
                single(.failure(JsonLoadError.fileNotFound))
                return Disposables.create()
            }
            
            guard let data = try? Data(contentsOf: url) else {
                single(.failure(JsonLoadError.dataLoadFailed))
                return Disposables.create()
            }
            
            do {
                let decoded = try self.decoder.decode(T.self, from: data)
                single(.success(decoded))
            } catch {
                single(.failure(JsonLoadError.decodingFailed))
            }
            
            return Disposables.create()
        }
    }
}
