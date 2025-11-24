//
//  JsonLoadError.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import Foundation


enum JsonLoadError: LocalizedError {
    case fileNotFound
    case dataLoadFailed
    case decodingFailed
    
    var errorDescription: String? {
        switch self {
        case  .fileNotFound:
            return "파일을 찾을 수 없습니다."
        case .dataLoadFailed:
            return "데이터 로딩에 실패했습니다."
        case .decodingFailed:
            return "디코딩에 실패했습니다."
        }
    }
}
