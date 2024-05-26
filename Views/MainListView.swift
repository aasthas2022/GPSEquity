//
//  MainListView.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/13/24.
//

import SwiftUI
import XCAStocksAPI
import FirebaseAuth

struct MainListView: View {
    @State private var isUserAuthenticated = false
    @StateObject var quotesVM = QuotesViewModel()
    @StateObject var searchVM = SearchViewModel()
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        VStack{
            Spacer()
            if isUserAuthenticated{
                MainListView2(isUserAuthenticated: $isUserAuthenticated, quotesVM: quotesVM, searchVM: searchVM).environment(\.colorScheme, .dark).background(.black)
            } else {
                SignInView(isUserAuthenticated: $isUserAuthenticated).environment(\.colorScheme, .dark)
            }
            Spacer()
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.black.ignoresSafeArea())
    }
}

struct MainListView2: View {
    @Binding var isUserAuthenticated: Bool
    @EnvironmentObject var appVM: AppViewModel
    @StateObject var quotesVM = QuotesViewModel()
    @StateObject var searchVM = SearchViewModel()
    // Color Based on ColorScheme...
    @Environment(\.colorScheme) var scheme
    
    var body: some View {
        TabView{
            NavigationView {
                dashboardView
                    .listStyle(.plain)
                    .overlay { dashOverlayView }
                    .toolbar{
                        titleToolbar
                        
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button("Logout", action: {
                                    try? Auth.auth().signOut()
                                    isUserAuthenticated = false
                                })
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                    .searchable(text: $searchVM.query)
                    .task {
                        await appVM.loadTickers()
                    }
                    .sheet(item: $appVM.selectedTicker) {
                        StockTickerView(chartVM: ChartViewModel(ticker: $0, apiService: quotesVM.stocksAPI), quoteVM: .init(ticker: $0,
                                                                                                                            stocksAPI: quotesVM.stocksAPI))
                        .presentationDetents([.height(560)])
                        .presentationBackground(.thickMaterial)
                    }
            }
            .tabItem {
                Image(systemName: "iphone.homebutton")
                Text("Dashboard")
            }
            NavigationView {
                tickerListView
//                    .background(Color(hex: 0x010b26))
                    .listStyle(.plain)
                    .overlay { overlayView }
                    .toolbar{
                        favoritesToolbar
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Menu {
                                Button("Logout", action: {
                                    try? Auth.auth().signOut()
                                    isUserAuthenticated = false

                                })
                            } label: {
                                Image(systemName: "ellipsis.circle")
                            }
                        }
                    }
                    .searchable(text: $searchVM.query)
                    .refreshable {
                        await quotesVM.fetchQuotes(tickers: appVM.tickers)
                    }
                    .sheet(item: $appVM.selectedTicker) {
                        StockTickerView(chartVM: ChartViewModel(ticker: $0, apiService: quotesVM.stocksAPI), quoteVM: .init(ticker: $0,
                                                                                                                            stocksAPI: quotesVM.stocksAPI))
                        .presentationDetents([.height(560)])
                        .presentationBackground(.thickMaterial)
                    }
                    .task(id: appVM.tickers){
                        await quotesVM.fetchQuotes(tickers: appVM.tickers)
                    }
            }
            .tabItem {
            Image(systemName: "chart.line.uptrend.xyaxis")
            Text("Stock Tracker")
            }
            NavigationView {
                LearnView()
            }.toolbar{
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Logout", action: {
                            try? Auth.auth().signOut()
                            
                            isUserAuthenticated = false

                        })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .tabItem {
                Image(systemName: "book")
                Text("Tutorials")
            }
            NavigationView {
                ContentView()
            }.toolbar{
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Logout", action: {
                            try? Auth.auth().signOut()
                            
                            isUserAuthenticated = false

                        })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .tabItem {
                Image(systemName: "newspaper")
                Text("Blogs")
            }
            NavigationView {
                MultimodalChatView()
            }.toolbar{
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("Logout", action: {
                            try? Auth.auth().signOut()
                            
                            isUserAuthenticated = false

                        })
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
            .tabItem {
                Image(systemName: "bubble")
                Text("Chat Assistant")
            }
        }
        .padding(.vertical, 20)
        .navigationViewStyle(StackNavigationViewStyle())
        .environment(\.colorScheme, .dark)
    }
    
    private var dashboardView: some View {
    
        return VStack(alignment: .leading, spacing: 10) {
            Text("Our Picks").font(.title2.weight(.heavy)).padding()
            List {
                ForEach(appVM.dashTickers) { ticker in
                    TickerListRowView(
                        data: .init(
                            symbol: ticker.symbol,
                            name: ticker.shortname,
                            price: quotesVM.priceForTicker(ticker),
                            type: .search(
                                isSaved: appVM.isAddedToMyTickers(ticker: ticker),
                                onButtonTapped: {
                                    Task { @MainActor in
                                        await appVM.toggleTicker(ticker)
                                    }
                                }
                            )))
                    .contentShape(Rectangle())
                    .onTapGesture {
                        appVM.selectedTicker = ticker
                    }
                }
                .onDelete { appVM.removeTickers(atOffsets: $0) }
            }
//            .background(Color(hex: 0x010b26))
        }
    }
    
    private var tickerListView: some View {
        List {
            ForEach(appVM.tickers) { ticker in
                TickerListRowView(
                    data: .init(
                        symbol: ticker.symbol,
                        name: ticker.shortname,
                        price: quotesVM.priceForTicker(ticker),
                        type: .search(
                            isSaved: appVM.isAddedToMyTickers(ticker: ticker),
                            onButtonTapped: {
                                Task { @MainActor in
                                    await appVM.toggleTicker(ticker)
                                }
                            }
                        )))
                .contentShape(Rectangle())
                .onTapGesture {
                    appVM.selectedTicker = ticker
                }
            }
            .onDelete { appVM.removeTickers(atOffsets: $0) }
        }
//        .background(Color(hex: 0x010b26))
    }
    
    @ViewBuilder
    private var overlayView: some View {
        if appVM.tickers.isEmpty {
            EmptyStateView(text: appVM.emptyTickersText)
        }
        
        if searchVM.isSearching {
            SearchView(searchVM: searchVM)
        }
    }
    @ViewBuilder
    private var dashOverlayView: some View {
        
        if searchVM.isSearching {
            SearchView(searchVM: searchVM)
        }
    }
    
    private var titleToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            VStack(alignment: .leading, spacing: 4) {
                Text(appVM.titleText)
            }.font(.title2.weight(.heavy))
        }
    }
    
    private var favoritesToolbar: some ToolbarContent {
        ToolbarItem(placement: .navigationBarLeading) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Favorites")
            }.font(.title2.weight(.heavy))
        }
    }
    
    
    struct MainListView_Previews: PreviewProvider {
        
        @StateObject static var appVM: AppViewModel = {
            var mock = MockTickerListRepository()
            mock.stubbedLoad = { Ticker.stubs }
            return AppViewModel(repository: mock)
        }()
        
        @StateObject static var emptyAppVM: AppViewModel = {
            var mock = MockTickerListRepository()
            mock.stubbedLoad = { [] }
            return AppViewModel(repository: mock)
        }()
    
       static var quotesVM: QuotesViewModel = {
           var mock = MockStocksAPI()
           mock.stubbedFetchQuotesCallback = { Quote.stubs }
           return QuotesViewModel(stocksAPI: mock)
       }()
       
       static var searchVM: SearchViewModel = {
           var mock = MockStocksAPI()
           mock.stubbedSearchTickersCallback = { Ticker.stubs }
           return SearchViewModel(stocksAPI: mock)
       }()
        
        static var previews: some View {
            Group {
                NavigationStack {
                    MainListView(quotesVM: quotesVM, searchVM: searchVM)
                }
                .environmentObject(appVM)
                .previewDisplayName("With Tickers")
                
                NavigationStack {
                    MainListView(quotesVM: quotesVM, searchVM: searchVM)
                }
                .environmentObject(emptyAppVM)
                .previewDisplayName("With Empty Tickers")
            }
        }
    }
}
