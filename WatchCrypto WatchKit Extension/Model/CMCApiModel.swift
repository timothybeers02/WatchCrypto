

import Foundation

//Contains all data from call, specific coin data accessible by index on data (data[index])
struct Response: Codable/*, Hashable*/ {
    private enum CodingKeys : String, CodingKey { case data = "data" }
    let data : [Crypto]
}

//Contains the coins name symbol max supply and all price information accessible by index (priceInformation[index])
    //priceInformation[x] = 0 for usd, 1 for btc
struct Crypto: Codable, Identifiable {
    
    var id = UUID()
    
    private enum CodingKeys : String, CodingKey {
        case name = "name"
        case symbol = "symbol"
        case maxSupply = "max_supply"
        case priceInformationType = "quote"
        case circulatingSupply = "circulating_supply"
    }
    let name: String
    let symbol: String
    let maxSupply: Int?
    let circulatingSupply: Double?
    let priceInformationType: PriceInformationType
}

//Contains Dollar and Bitcoin conversion info
struct PriceInformationType: Codable {
    private enum CodingKeys : String, CodingKey {
        case usd = "USD"
    }
    let usd: usdInfo
}

struct usdInfo: Codable {
    private enum CodingKeys : String, CodingKey {
        case price = "price"
        case percentChange1h = "percent_change_1h"
        case percentChange24h = "percent_change_24h"
        case percentChange7d = "percent_change_7d"
        case lastUpdated = "last_updated"
        case volume = "volume_24h"
        case volumeChange24h = "volume_change_24h"
        case marketCap = "market_cap"
    }
    
    let price: Double
    let percentChange1h: Double
    let percentChange24h: Double
    let percentChange7d: Double
    let lastUpdated: String
    let volume: Double
    let volumeChange24h: Double
    let marketCap: Double
}

class apiCall {
    func getCryptos() -> Response {
        var response: Response = Response(data: [])
        //Checks valid url
        guard let url = URL(string: "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest") else { return Response(data: []) }
        //create request from url
        var request = URLRequest(url: url)
        //Adds API key to header
        request.addValue("47d1b5bd-f89d-489d-81e0-a81fe258c8f4", forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        //decodes api call to Response struct, assigning to response var
        URLSession.shared.dataTask(with: request) { (data, _, _) in
            if let data = data {
                let cryptos: Response = try! JSONDecoder().decode(Response.self, from: data)
    //            print(cryptos)

                response = cryptos
            } else {
                print("No data found in network call")
            }
            
        }
        .resume()
        
        return response
    }
    
    func getCryptos(completion:@escaping (Response) -> ()) {
        //Checks valid url
        guard let url = URL(string: "https://pro-api.coinmarketcap.com/v1/cryptocurrency/listings/latest") else { return }
        //create request from url
        var request = URLRequest(url: url)
        //Adds API key to header
        request.addValue("47d1b5bd-f89d-489d-81e0-a81fe258c8f4", forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        //decodes api call to Response struct, providing data as completion variable
        URLSession.shared.dataTask(with: request) { (data, _, _) in
            if let data = data {
                let cryptos: Response = try! JSONDecoder().decode(Response.self, from: data)

                DispatchQueue.main.async {
                    completion(cryptos)
                }
                
            } else {
                print("No data found in network call")
            }
            
        }
        .resume()
    }
}
