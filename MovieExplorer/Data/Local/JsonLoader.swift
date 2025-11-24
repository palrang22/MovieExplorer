//
//  JsonLoader.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import Foundation


final class JsonLoader {
    private let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    func load<T:Decodable>(fileName: String) throws -> T {
        guard let url = Bundle.main.url(forResource: fileName, withExtension: "json") else {
            throw JsonLoadError.fileNotFound
        }
        
        guard let data = try? Data(contentsOf: url) else {
            throw JsonLoadError.dataLoadFailed
        }
        
        do {
            let decoded = try decoder.decode(T.self, from: data)
            return decoded
        } catch {
            throw JsonLoadError.decodingFailed
        }
    }
}
