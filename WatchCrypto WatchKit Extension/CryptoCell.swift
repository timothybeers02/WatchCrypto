//
//  CryptoCell.swift
//  WatchCrypto WatchKit Extension
//
//  Created by Timothy Beers on 3/23/22.
//

import SwiftUI

struct CryptoCell: View {
    
    @Namespace var animation
    @State var expanded: Bool = false
    @State var icon: String
    @State var symbol: String
    @State var price: Double
    @State var name: String
    @State var percentChange1h: String
    @State var percentChange24h: String
    @State var percentChange7d: String
    @State var volume: String
    @State var volumeChange: String
    @State var marketCap: String
    @State var positive24hChange: Bool
    @State var positive1hChange: Bool
    @State var positive7dChange: Bool
    @State var volumePositive: Bool
    @ObservedObject var info: CryptoInfo
    
    init(crypto: Crypto, info: CryptoInfo) {
        icon = crypto.symbol.lowercased()
        symbol = crypto.symbol
        name = crypto.name
        price = crypto.priceInformationType.usd.price
        positive24hChange = (crypto.priceInformationType.usd.percentChange24h > 0)
        percentChange1h = String(format: "%.2f", crypto.priceInformationType.usd.percentChange1h)
        percentChange24h = String(format: "%.1f", crypto.priceInformationType.usd.percentChange24h)
        percentChange7d = String(format: "%.1f", crypto.priceInformationType.usd.percentChange7d)
        positive1hChange = (crypto.priceInformationType.usd.percentChange1h > 0)
        positive24hChange = (crypto.priceInformationType.usd.percentChange24h > 0)
        positive7dChange = (crypto.priceInformationType.usd.percentChange7d > 0)
        volume = info.addCommas(to: String(format: "%.0f", crypto.priceInformationType.usd.volume))
        volumeChange = String(format: "%.1f", crypto.priceInformationType.usd.volumeChange24h)
        volumePositive = (crypto.priceInformationType.usd.volumeChange24h > 0)
        marketCap = info.addCommas(to: String(format: "%.0f", crypto.priceInformationType.usd.marketCap))
        self.info = info
    }
    
    var body: some View {
        ZStack {
            if expanded {
                cryptoInfoExpanded.matchedGeometryEffect(id: "ExpandedCell", in: animation)
            } else {
                cryptoInfo.matchedGeometryEffect(id: "CollapsedCell", in: animation)
            }
        }
        .padding()
        .background(Color("alertViewBackground"))
        .mask(RoundedRectangle(cornerRadius: 20))
        .onTapGesture {
            withAnimation(.linear) {
                expanded.toggle()
            }
        }
    }
    
    var cryptoInfo: some View {
        HStack {
            iconView
            symbolAndName
            Spacer()
            priceAndPercent
        }
    }
    
    var cryptoInfoExpanded: some View {
        VStack {
            cryptoInfo
            HStack {
                VStack {
                    HStack {
                        Spacer()
                        Button(action: {
                            if info.watchedSymbols[symbol] == true {
                                info.unwatchSymbol(symbol)
                            } else {
                                info.watchSymbol(symbol)
                            }
                        }) {
                            if info.watchedSymbols[symbol] == true {
                                Text("Unwatch")
                            } else {
                                Text("Watch")
                            }
                        }
                        Spacer()
                    }
                    HStack {
                        Text("1h\t")
                        Spacer()
                        Text(addPercentSymbolsToString(percentChange1h)).foregroundColor(positive1hChange ? .green : .red)
                    }
                    Divider()
                    HStack {
                        Text("24h\t")
                        Spacer()
                        Text(addPercentSymbolsToString(percentChange24h)).foregroundColor(positive24hChange ? .green : .red)
                    }
                    Divider()
                    HStack {
                        Text("7d\t")
                        Spacer()
                        Text(addPercentSymbolsToString(percentChange7d)).foregroundColor(positive7dChange ? .green : .red)
                    }
                    Divider()
                    HStack {
                        Text("MC\t")
                        Spacer()
                        Text(marketCap)
                    }
                    Divider()
                    HStack(alignment: .top) {
                        Text("Vol\t")
                        Spacer()
                        VStack(alignment: .trailing) {
                            Text(volume)
                            Text(addPercentSymbolsToString(volumeChange)).foregroundColor(volumePositive ? .green : .red)
                        }
                    }
//                    Spacer()
                }.font(.footnote).lineLimit(1)
            }.padding(.top, 2.5)
        }
    }
    
    var iconView: some View {
        Image(icon)
            .renderingMode(.template)
            .resizable()
            .frame(width: 40, height: 40)
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.primary)
            .clipped()
    }
    
    var symbolAndName: some View {
        VStack(alignment: .leading) {
            Text(symbol).fontWeight(.bold)
            Text(name).font(.footnote).lineLimit(1)
        }
    }
    
    var priceAndPercent: some View {
        VStack(alignment: .trailing) {
            Text("$" + watchViewShortenedPrice(price)).lineLimit(1).matchedGeometryEffect(id: "PriceText", in: animation)
            if !expanded {
                Text(percentChange24h + "%").font(.footnote)
            }
        }.foregroundColor(positive24hChange ? .green : .red)
    }
}

func watchViewShortenedPrice(_ price: Double) -> String {
    if price < 10 {
        return String(format: "%.2f", price)
    } else if price < 1000 {
        return String(format: "%.1f", price)
    } else if price < 1000000 {
        let thousands: Double = price / 1000
        let thousandsString: String = String(format: "%.1f", thousands)
        return String(thousandsString + "K")
    } else {
        let millions: Double = price / 1000000
        let millionsString: String = String(format: "%.1f", millions)
        return String(millionsString + "M")
    }
}

func addPercentSymbolsToString(_ str: String) -> String {
    let stringAsDouble: Double? = Double(str)
    if let stringAsDouble = stringAsDouble {
        let positive = stringAsDouble > 0
        if positive {
            return "+" + str + "%"
        } else {
            return str + "%"
        }
    } else {
        return str
    }
}

