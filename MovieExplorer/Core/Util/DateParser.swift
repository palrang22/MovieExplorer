//
//  DateParser.swift
//  MovieExplorer
//
//  Created by 김승희 on 11/24/25.
//

import Foundation


enum DateParser {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "ko-KR")
        return formatter
    }()
    
    static func parse(stringDate: String) -> Date? {
        return dateFormatter.date(from: stringDate)
    }
}
