//
//  TikcerListRepository.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import Foundation
import XCAStocksAPI
import Firebase
import FirebaseFirestore


protocol TickerListRepository {
    func save(_ current: [Ticker]) async throws
    func saveDash(_ current: [Ticker]) throws
    func load() async throws -> [Ticker]
    func loadDash() async throws -> [Ticker]
}

class TickerPlistRepository: TickerListRepository {
    
    private var saved: [Ticker]?
    
    func save(_ current: [Ticker]) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            throw NSError(domain: "FirebaseTickerRepository", code: 1, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
        }
        let tickersData = current.map { $0.dictionary }
        let db = Firestore.firestore()
        let tickersRef = db.collection("users").document(userID).collection("tickers")

        // Fetch documents to delete
        let documents = try await tickersRef.getDocuments().documents
        let batch = db.batch()
        documents.forEach { doc in
            batch.deleteDocument(doc.reference)
        }

        // Set new data
        tickersData.forEach { ticker in
            let docRef = tickersRef.document(ticker["symbol"] as! String)
            batch.setData(ticker, forDocument: docRef)
        }

        // Commit batch
        try await batch.commit()
    }

     
    
    func saveDash(_ current: [Ticker]) throws {
        self.saved = dashStoxList
    }
    
    
    
    // Updated to use Firebase for loading
        func load() async throws -> [Ticker] {
            guard let userID = Auth.auth().currentUser?.uid else {
                throw NSError(domain: "FirebaseTickerRepository", code: 2, userInfo: [NSLocalizedDescriptionKey: "User not logged in"])
            }
            let db = Firestore.firestore()
            let tickersRef = db.collection("users").document(userID).collection("tickers")
            
            return try await withCheckedThrowingContinuation { continuation in
                tickersRef.getDocuments { (querySnapshot, err) in
                    if let err = err {
                        continuation.resume(throwing: err)
                    } else if let querySnapshot = querySnapshot {
                        let tickers = querySnapshot.documents.compactMap { doc -> Ticker? in
                            if let symbol = doc.data()["symbol"] as? String, let shortname = doc.data()["shortname"] as? String {
                                return Ticker(symbol: symbol, shortname: shortname)
                            }
                            return nil
                        }
                        continuation.resume(returning: tickers)
                    }
                }
            }
        }
    
    func loadDash() throws -> [Ticker] {
        return dashStoxList
    }
}

extension Ticker {
    var dictionary: [String: Any] {
        return ["symbol": symbol, "shortname": shortname ?? "", "longname": longname ?? "", "sector": sector ?? "", "industry": industry ?? "", "exchDisp": exchDisp ?? ""]
    }
}


let nvda = Ticker(symbol: "NVDA", quoteType: Optional("EQUITY"), shortname: Optional("NVIDIA Corporation"), longname: Optional("NVIDIA Corporation"), sector: Optional("Technology"), industry: Optional("Semiconductors"), exchDisp: Optional("NASDAQ"))
let goog = Ticker(symbol: "GOOG", quoteType: Optional("EQUITY"), shortname: Optional("Alphabet Inc."), longname: Optional("Alphabet Inc."), sector: Optional("Communication Services"), industry: Optional("Internet Content & Information"), exchDisp: Optional("NASDAQ"))
let amzn = Ticker(symbol: "AMZN", quoteType: Optional("EQUITY"), shortname: Optional("Amazon.com, Inc."), longname: Optional("Amazon.com, Inc."), sector: Optional("Consumer Cyclical"), industry: Optional("Internet Retail"), exchDisp: Optional("NASDAQ"))
let msft = Ticker(symbol: "MSFT", quoteType: Optional("EQUITY"), shortname: Optional("Microsoft Corporation"), longname: Optional("Microsoft Corporation"), sector: Optional("Technology"), industry: Optional("Software—Infrastructure"), exchDisp: Optional("NASDAQ"))
let amd = Ticker(symbol: "AMD", quoteType: Optional("EQUITY"), shortname: Optional("Advanced Micro Devices, Inc."), longname: Optional("Advanced Micro Devices, Inc."), sector: Optional("Technology"), industry: Optional("Semiconductors"), exchDisp: Optional("NASDAQ"))
let amc = Ticker(symbol: "AMC", quoteType: Optional("EQUITY"), shortname: Optional("AMC Entertainment Holdings, Inc"), longname: Optional("AMC Entertainment Holdings, Inc."), sector: Optional("Communication Services"), industry: Optional("Entertainment"), exchDisp: Optional("NYSE"))
let gme = Ticker(symbol: "GME", quoteType: Optional("EQUITY"), shortname: Optional("GameStop Corporation"), longname: Optional("GameStop Corp."), sector: Optional("Consumer Cyclical"), industry: Optional("Specialty Retail"), exchDisp: Optional("NYSE"))
let riv = Ticker(symbol: "RIVN", quoteType: Optional("EQUITY"), shortname: Optional("Rivian Automotive, Inc."), longname: Optional("Rivian Automotive, Inc."), sector: Optional("Consumer Cyclical"), industry: Optional("Auto Manufacturers"), exchDisp: Optional("NASDAQ"))
let rbnhood = Ticker(symbol: "HOOD", quoteType: Optional("EQUITY"), shortname: Optional("Robinhood Markets, Inc."), longname: Optional("Robinhood Markets, Inc."), sector: Optional("Financial Services"), industry: Optional("Capital Markets"), exchDisp: Optional("NASDAQ"))
let bb = Ticker(symbol: "BB", quoteType: Optional("EQUITY"), shortname: Optional("BlackBerry Limited"), longname: Optional("BlackBerry Limited"), sector: Optional("Technology"), industry: Optional("Software—Infrastructure"), exchDisp: Optional("NYSE"))

let dashStoxList = [amc, nvda, gme, goog, riv, amzn, bb, msft, amd, rbnhood]
