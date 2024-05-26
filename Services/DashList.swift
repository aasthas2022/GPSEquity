//
//  DashList.swift
//  GPSEquity
//
//  Created by Anuj Purandare on 4/30/24.
//

import Foundation
import XCAStocksAPI

class DashStocks {
    let nvda = Ticker(symbol: "NVDA", quoteType: Optional("EQUITY"), shortname: Optional("NVIDIA Corporation"), longname: Optional("NVIDIA Corporation"), sector: Optional("Technology"), industry: Optional("Semiconductors"), exchDisp: Optional("NASDAQ"))
    let goog = Ticker(symbol: "GOOG", quoteType: Optional("EQUITY"), shortname: Optional("Alphabet Inc."), longname: Optional("Alphabet Inc."), sector: Optional("Communication Services"), industry: Optional("Internet Content & Information"), exchDisp: Optional("NASDAQ"))
}
