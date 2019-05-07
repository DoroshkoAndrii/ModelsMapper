//
//  ViewController.swift
//  ModelsMapper
//
//  Created by Andrey Doroshko on 5/3/19.
//  Copyright © 2019 Andrey Doroshko. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var versesData: decode?
    
    @IBOutlet weak var textView: UITextView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Read from JSON
        do {
            if let versesUrl = Bundle.main.url(forResource: "verses", withExtension: "json") {
                let json = try String(contentsOf: versesUrl, encoding: .utf8)
                if let jsonData = json.data(using: .utf8) {
                    let jsonDecoder = JSONDecoder()
                    self.versesData = try jsonDecoder.decode(decode.self, from: jsonData)
//                    print(versesData)
                }
            }
        } catch let error {
            print(error)
        }
        // Map Models 
        guard let tags = (versesData?.data.map { $0.best_felt_needs }.flatMap { $0 }) else { return }
        let tagss = Array(Set(tags))
        let mytags = tagss.map{ tag in
           return versesData?.tags.first(where: { $0.name.caseInsensitiveCompare(tag) == ComparisonResult.orderedSame})
            }.flatMap { $0 }
        
        guard let vers = (versesData?.data.map { VerseModel.from(verse: $0, tags: mytags) }) else { return }

        // write new JSON
        do {
        let st = VersesData(tags: mytags, verses: vers)
        let fileUrl = Bundle.main.url(forResource: "File", withExtension: "json")!
        let jsonEncoder = JSONEncoder()
        let jsonData = try jsonEncoder.encode(st)
        let json = String(data: jsonData, encoding: String.Encoding.utf8)
            textView.text = json
        try json?.write(to: fileUrl, atomically: true, encoding: .utf8)
        } catch let error {
            
        }
        
    }
    
}

private struct VersesData: Codable {
    var tags: [TagModel]
    let verses: [VerseModel]
}

struct TagModel: Codable {
    let id: String
    let type: TagModelType
    let name: String
}

enum TagModelType: String, Codable {
    case struggle
    case grow
}

struct VerseModel: Codable {
    let id: Int
    let tagIds: [String]
    let title: String
    let description: String
    
    static func from(verse: Verse, tags: [TagModel]) -> VerseModel {
        let tagIds = verse.best_felt_needs.map { item in
            return tags.first(where: { $0.name.caseInsensitiveCompare(item) == ComparisonResult.orderedSame })?.id
            }.flatMap {$0}
        return .init(id: verse.id, tagIds: tagIds, title: verse.title, description: verse.content)
    }
}

struct Verse: Codable {
    let id: Int
    let title: String
    let best_felt_needs: [String]
    let content: String
    let questions: String?
    let url: String?
    let video_url: String?
    let audio: String?
    let embeded_url: String?
    let preview: String?
    let image: Image?
    let verses: [Verse2]?
}

struct Image: Codable {
    let large: String?
    let small: String?
}

struct Verse2: Codable {
    let complete_reference: String
    let book: String
    let chapter: String
    let verse: String
    let url: String
}
struct decode: Codable {
    let data: [Verse]
    let tags: [TagModel]
}

