//
//  Ayah.swift
//  Quran
//
//  Created by Eslam Hanafy on 3/21/18.
//  Copyright © 2018 magdsoft. All rights reserved.
//

import Foundation
import SQLite

class Ayah {
    var id: Int64
    var content: String
    var page: Int64
    var dbId: Int64
    var isBookmarked: Bool
    
    init(id: Int64, dbId: Int64 = 0, content: String = "", page: Int64 = 0, isBookmarked: Bool = false) {
        self.id = id
        self.dbId = dbId
        self.content = content
        self.page = page
        self.isBookmarked = isBookmarked
    }
    
    init(fromRow row: Row) {
        let ayahTable = Table("ayah")
        let number = Expression<Int64>("number")
        let text = Expression<String>("text")
        let pageNumber = Expression<Int64>("page")
        let id = Expression<Int64>("id")
        let isMarked = Expression<Int64?>("is_bookmarked")
        
        self.id = row[ayahTable[number]]
        self.content = row[ayahTable[text]]
        self.page = row[ayahTable[pageNumber]]
        self.dbId = row[ayahTable[id]]
        self.isBookmarked = row[ayahTable[isMarked]] == 1
    }
}
