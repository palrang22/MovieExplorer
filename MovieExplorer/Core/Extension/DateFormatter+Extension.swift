//
//  DateFormatter+Extension.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import Foundation

import Then


extension DateFormatter {
    static let dateDividedByDash = DateFormatter().then {
        $0.dateFormat = "yyyy-MM-dd"
    }
    
    static let dateDividedByDot = DateFormatter().then {
        $0.dateFormat = "yyyy.MM.dd"
    }
}
