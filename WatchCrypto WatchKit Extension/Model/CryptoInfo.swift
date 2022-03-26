

import Foundation

class CryptoInfo: ObservableObject {

    var timeZoneSeconds: Int { return TimeZone.current.secondsFromGMT() }
    let currentTime = Date()
    
    //cryptos with no logo
    let excludedSymbols: [String] = [
        "LUNA", "AVAX", "BUSD", "CRO", "AXS", "BTCB", "FTT", "HBAR", "EGLD", "FTM",
        "NEAR", "UST", "HNT", "CAKE", "FLOW", "KLAY", "XEC", "QNT", "KDA", "CHZ",
        "RUNE", "AR", "CELO", "TFUEL", "OKB", "WAXP", "MINA", "REV", "AUDIO", "XDC",
        "SHIB", "APE", "GALA", "CVX", "USDP", "ROSE", "XYM", "BORA", "SCRT", "CEL",
        "SXP", "USDN"
    ]
    
    var data: Response = apiCall().getCryptos()
    
    let defaults = UserDefaults.standard
    @Published var errMsg = ""
    @Published var watchedSymbols: [String : Bool] = [:]
    @Published var cryptos: [Crypto] = []                                           //Use left to access:
    //cryptos[i]                                                                    /Crypto
    //        //.name                                                               //Name eg. "Bitcoin"
    //        //.symbol                                                             //Symbol eg. "BTC"
    //        //.maxSupply                                                          //Max Supply eg. 1,000,000,000
    //        //.priceInformationType                                               /Sublayer of available currency conversions
    //        //                   //.usd                                           /Sublayer of price information for the chosen currency
    //        //                       //.price                                     //Price eg. 63,000.45
    //        //                       //.percentChange24h                          //Percent change in the last 24h eg. 7.45
    //        //                       //.lastUpdated                               //Last Updated Date and Time eg. 2021-06-01T22:11:00.000Z
    

    
    
    func refresh() {
        
        var cPlaceholder: [Crypto] = []
        
        for crypto in data.data {
            if !excludedSymbols.contains(crypto.symbol) {
                cPlaceholder.append(crypto)
//                print("appended to placeholder")
            }
        }
        
        cryptos = cPlaceholder
//        print("cryptos refreshed******")
    }
    
    func lastUpdated() -> String {
        if cryptos.count > 0 {
            //separates time from api call into list [0 index for date, 1 index for time]
            var list: [String] = []
            list = cryptos[0].priceInformationType.usd.lastUpdated.components(separatedBy: "T")
            //access the time and assign to hour minute seconds
            let hms = list[1].components(separatedBy: ":")
            //Returns hour formatted to time zone and minutes in a string
            return (determineHourString(hms[0]) + ":" + hms[1] + determineAmPmFrom(hour: hms[0]))
        } else { return "Just Now" }
    }
    
    ///Calculates the hour to be displayed by converting the api hour into the users time zone
    func determineHourString(_ apiHourString: String) -> String {
        
        let hourDifference = timeZoneSeconds / 3600
        
        var returnHour: Int
        
        switch(apiHourString) {
        case "12", "00":
            returnHour = (12 + hourDifference)
        case "11", "23":
            returnHour = (11 + hourDifference)
        case "10", "22":
            returnHour = (10 + hourDifference)
        case "09", "21":
            returnHour = (9 + hourDifference)
        case "08", "20":
            returnHour = (8 + hourDifference)
        case "07", "19":
            returnHour = (7 + hourDifference)
        case "06", "18":
            returnHour = (6 + hourDifference)
        case "05", "17":
            returnHour = (5 + hourDifference)
        case "04", "16":
            returnHour = (4 + hourDifference)
        case "03", "15":
            returnHour = (3 + hourDifference)
        case "02", "14":
            returnHour = (2 + hourDifference)
        case "01", "13":
            returnHour = (1 + hourDifference)
        default:
            return apiHourString
        }
        
        if returnHour < 0 {
            returnHour = 12 + returnHour
        }
        
        return String(returnHour)
    }
    
    ///calculates whether it is am or pm for the user depending on the hour the api currently returns
    func determineAmPmFrom(hour apiHourString: String) -> String {
        
        let hourDifference = timeZoneSeconds / 3600
        var intFromHourString: Int
        var hourAfterTimeChange: Int
        
        //Convert string to int
        if apiHourString == "00" {
            intFromHourString = 0
        } else {
            intFromHourString = Int(apiHourString)!
        }
        
        //Calculate hourAfterTimeChange, considering negatives
        if (intFromHourString + hourDifference) < 0 {
            hourAfterTimeChange = 24 + (intFromHourString + hourDifference)
        } else {
            hourAfterTimeChange = (intFromHourString + hourDifference)
        }
        
        //Calculate amPm based on hourAfterTimeChange
        if hourAfterTimeChange >= 0 && hourAfterTimeChange < 12 {
            return "am"
        } else {
            return "pm"
        }
        
    }
    
    func watchSymbol(_ sym: String) {
//        watchedSymbols.append(sym)
        watchedSymbols[sym] = true
        defaults.set(watchedSymbols, forKey: "WatchedSymbolsDict")
    }
    
    func unwatchSymbol(_ sym: String) {
//        for symbol in watchedSymbols {
//            if watchedSymbols[count] == sym {
//                watchedSymbols.remove(at: count)
//            }
//        }
        watchedSymbols[sym] = false
        defaults.set(watchedSymbols, forKey: "WatchedSymbolsDict")
    }
    
    func watchedSymbolsCount() -> Int {
        
        var counter = 0
        
        for symbol in watchedSymbols {
            if symbol.value == true {
                counter += 1
            }
        }
        
        return counter
    }
    
    func addCommas(to str: String) -> String {
        
        var list: [String] = []
        list = str.components(separatedBy: ".")
        let decRemoved = list[0]
        var reverseReturnString = ""
        var count = 0
        
        for character in decRemoved.reversed() {
            if count != 0 && count % 3 == 0 {
                reverseReturnString.append(",")
            }
            reverseReturnString.append(character)
            count += 1
        }
        
        let returnStringArr = {
            list.count > 1 ?
            reverseReturnString.reversed() + "." + list[1] :
            reverseReturnString.reversed()
        }()
        
        var returnString = ""
        for char in returnStringArr {
            returnString.append(char)
        }
        
        return returnString
    }
    
}
