//
//  AppViewModel.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import Foundation
import SwiftUI
import XCAStocksAPI
import FirebaseAuth

@MainActor
class AppViewModel: ObservableObject {
    private var authHandle: AuthStateDidChangeListenerHandle?

    @Published var tickers: [Ticker] = [] {
        didSet { Task {await saveTickers() }}
    }
    
    @Published var dashTickers: [Ticker] = [] {
        didSet{ saveDashTickers() }
    }
    
    @Published var selectedTicker: Ticker?
 
    var titleText = "GPSEquity"
    @Published var subtitleText: String
    var emptyTickersText = "Add your Favorite Stocks Here"
    
    
    private let subtitleDateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateFormat = "d MMM"
        return df
    }()
    
    let tickerListRepository: TickerListRepository
    
    
    
    
    init(repository: TickerListRepository = TickerPlistRepository()) {
        self.tickerListRepository = repository
        self.subtitleText = subtitleDateFormatter.string(from: Date())
        loadTickers()
        loadDashTickers()
        observeAuthChanges()
    }
    
    private func observeAuthChanges() {
            authHandle = Auth.auth().addStateDidChangeListener { [weak self] (auth, user) in
                if let user = user {
                    self?.loadTickers()
                } else {
                    self?.tickers = []
                }
            }
        }
    
    deinit {
            if let handle = authHandle {
                Auth.auth().removeStateDidChangeListener(handle)
            }
        }
    
    
    
    
    
    func loadTickers() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                self.tickers = try await tickerListRepository.load()
            } catch {
                print(error.localizedDescription)
                self.tickers = []
            }
        }
    }
    
    private func loadDashTickers() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                self.dashTickers = try await tickerListRepository.loadDash()
            } catch {
                print(error.localizedDescription)
                self.dashTickers = []
            }
        }
    }
    
    private func saveTickers() async {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try await self.tickerListRepository.save(self.tickers)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func saveDashTickers() {
        Task { [weak self] in
            guard let self = self else { return }
            do {
                try self.tickerListRepository.saveDash(self.dashTickers)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    
    func removeTickers(atOffsets offsets: IndexSet) {
        tickers.remove(atOffsets: offsets)
    }
    
    func isAddedToMyTickers(ticker: Ticker) -> Bool {
        return tickers.first { $0.symbol == ticker.symbol } != nil
    }
    
    func toggleTicker(_ ticker: Ticker) async {
        if isAddedToMyTickers(ticker: ticker) {
            await removeFromMyTickers(ticker: ticker)
        } else {
            await addToMyTickers(ticker: ticker)
        }
    }
    
    private func addToMyTickers(ticker: Ticker) async {
        tickers.append(ticker)
        await self.saveTickers()
    }
    
    private func removeFromMyTickers(ticker: Ticker) async {
        guard let index = tickers.firstIndex(where: { $0.symbol == ticker.symbol }) else { return }
        tickers.remove(at: index)
        await self.saveTickers()
    }
    
    func openYahooFinance() {
        let url = URL(string: "https://finance.yahoo.com")!
        guard UIApplication.shared.canOpenURL(url) else { return }
        UIApplication.shared.open(url)
    }
}
