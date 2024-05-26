//
//  MockTickerListRepository.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import Foundation
import XCAStocksAPI

#if DEBUG
struct MockTickerListRepository: TickerListRepository {
    
    var stubbedLoad: (() async throws -> [Ticker])!
    func load() async throws -> [Ticker] {
        try await stubbedLoad()
    }
    
    func loadDash() async throws -> [Ticker] {
        try await stubbedLoad()
    }
    
    func save(_ current: [Ticker]) async throws {}
    func saveDash(_ current: [Ticker]) throws {}
    
}


#endif
