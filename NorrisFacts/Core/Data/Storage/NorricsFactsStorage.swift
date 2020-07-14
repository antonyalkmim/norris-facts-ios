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
    
    /// get categories from local database
    func getCategories() -> Observable<[FactCategory]>
    /// save categories into local database
    func saveCategories(_ categories: [FactCategory])
    
    /// get facts from local database
    func getFacts(searchTerm: String) -> Observable<[NorrisFact]>
    /// save facts into local database
    func saveFacts(_ facts: [NorrisFact])
    
    /// save searches into local database
    func saveSearch(term: String, facts: [NorrisFact])
    
    /// get unique past searches terms sorted by date
    func getPastSearchTerms() -> Observable<[String]>
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
        try? self.realm.write {
            let entities = categories.map(RMFactCategory.init)
            self.realm.add(entities, update: .modified)
        }
    }
    
    func getFacts(searchTerm: String) -> Observable<[NorrisFact]> {
        
        var facts = realm.objects(RMNorrisFact.self)
            
        facts = searchTerm.isEmpty
            ? facts
            : facts.filter("ANY search.term = %@", searchTerm)
        
        return Observable.collection(from: facts)
            .map { $0.map { $0.object } }
    }
    
    func saveFacts(_ facts: [NorrisFact]) {
        try? realm.write {
            let entities = facts.map(RMNorrisFact.init)
            self.realm.add(entities, update: .modified)
        }
    }
    
    func saveSearch(term: String, facts: [NorrisFact]) {
        try? realm.write {
            let entity = RMSearch(term: term, facts: facts)
            self.realm.add(entity, update: .modified)
        }
    }
    
    func getPastSearchTerms() -> Observable<[String]> {
        let searches = realm.objects(RMSearch.self)
            .sorted(byKeyPath: "updatedAt", ascending: false)
        
        return Observable.collection(from: searches)
            .map { $0.map { $0.term } }
    }
}
