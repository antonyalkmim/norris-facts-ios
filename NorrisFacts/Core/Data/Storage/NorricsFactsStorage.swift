//
//  NorricsFactsStorage.swift
//  NorrisFacts
//
//  Created by Antony Nelson Daudt Alkmim on 04/07/20.
//  Copyright © 2020 Antony Nelson Daudt Alkmim. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift
import RxRealm

protocol NorrisFactsStorageType {
    func getCategories() -> Observable<[FactCategory]>
    func saveCategories(_ categories: [FactCategory])
    
    func getFacts(searchTerm: String) -> Observable<[NorrisFact]>
    func saveFacts(_ facts: [NorrisFact])
}

class NorrisFactsStorage: NorrisFactsStorageType {
    
    let realm: Realm!
    
    init(realm: Realm? = nil) {
        self.realm = realm ?? (try? Realm())
    }
    
    func getCategories() -> Observable<[FactCategory]> {
        Observable.collection(from: realm.objects(RMFactCategory.self))
            .map { $0.map { $0.object } }
    }
    
    func saveCategories(_ categories: [FactCategory]) {
        try? realm.write {
            let entities = categories.map(RMFactCategory.init)
            self.realm.add(entities, update: .modified)
        }
    }
    
    func getFacts(searchTerm: String) -> Observable<[NorrisFact]> {
        
        var facts = realm.objects(RMNorrisFact.self)
        
        // filter in case searchTerm is not empty
        facts = searchTerm.isEmpty
            ? facts
            : facts.filter("ANY categories.title = %@", searchTerm)
            
        return Observable.collection(from: facts)
            .map { $0.map { $0.object } }
    }
    
    func saveFacts(_ facts: [NorrisFact]) {
        try? realm.write {
            let entities = facts.map(RMNorrisFact.init)
            self.realm.add(entities, update: .modified)
        }
    }
    
}
