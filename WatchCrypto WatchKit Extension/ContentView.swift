//
//  ContentView.swift
//  WatchCrypto WatchKit Extension
//
//  Created by Timothy Beers on 3/23/22.
//

import SwiftUI

struct ContentView: View {
    
    @StateObject var info = CryptoInfo()
    @State var viewingWatchlist: Bool = false
    
    var body: some View {
        ZStack(alignment: .bottom) {
            scrollView
                .onAppear {
                    apiCall().getCryptos { data in
                        info.data = data
                        info.refresh()
                    }
                }
            Text(viewingWatchlist ? "Watchlist" : "All")
                .font(.footnote)
                .offset(y: 20)
                .foregroundColor(.blue)
        }.gesture(
            DragGesture(minimumDistance: 2.5, coordinateSpace: .local)
                .onEnded { value in
                    if value.translation.width < 0 && value.translation.height > -30 && value.translation.height < 30 {
                        if viewingWatchlist {
                            viewingWatchlist = false
                        }
                    } else if value.translation.width > 0 && value.translation.height > -30 && value.translation.height < 30 {
                        if !viewingWatchlist {
                            viewingWatchlist = true
                        }
                    }
                }
        )

        
    }
    
//    var errorCompatibableScrollView: some View {
//
//    }
    
    var scrollView: some View {
        ScrollView {
            refreshButton.padding(5)
            ForEach(info.cryptos) { crypto in
                //If (crypto is not in excluded symbols) and (nothing in search bar) -> show all results
                ZStack {
                if(!info.excludedSymbols.contains(crypto.symbol) && !viewingWatchlist) {
                    CryptoCell(crypto: crypto, info: info)
                        .shadow(radius: 1)
                } else if (!info.excludedSymbols.contains(crypto.symbol) && viewingWatchlist) {
                    if info.watchedSymbols[crypto.symbol] == true {
                        CryptoCell(crypto: crypto, info: info)
                            .shadow(radius: 1)
                    }
                }
                }
            }.padding(5)
        }

    }
    
    var refreshButton: some View {
        Button(action: {
            apiCall().getCryptos { data in
                info.data = data
                info.refresh()
            }
        }) {
            HStack {
                Spacer()
                VStack {
                    Image(systemName: "arrow.clockwise.circle")
                    Text("Last Updated: " + info.lastUpdated())
                }
                Spacer()
            }
            .padding()
            .background(Color("alertViewBackground"))
            .mask(RoundedRectangle(cornerRadius: 20))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
