//
//  ArticlsDataModel.swift
//  CoreMotionProject
//
//  Created by Yi-Cheng Lin on 2019/10/18.
//  Copyright © 2019 Yi-Cheng Lin. All rights reserved.
//

import Foundation

struct ArticlesData: Codable {
    let articles: [Articles]?
    
    enum CodingKeys: String, CodingKey {
        case articles
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        articles = try values.decodeIfPresent([Articles].self, forKey: .articles)
    }
}

struct Articles: Codable {
    let title: String?
    let desc: String?
    let quest: String?
    let options: [String]?
    let answer: Int?
    
    enum CodingKeys: String, CodingKey {
        case title
        case desc
        case quest
        case options
        case answer
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        title = try values.decodeIfPresent(String.self, forKey: .title)
        desc = try values.decodeIfPresent(String.self, forKey: .desc)
        quest = try values.decodeIfPresent(String.self, forKey: .quest)
        options = try values.decodeIfPresent([String].self, forKey: .options)
        answer = try? values.decodeIfPresent(Int.self, forKey: .answer)
    }
}
