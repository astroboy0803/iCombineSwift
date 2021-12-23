import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

enum Season: String, CaseIterable {
    case spring = "S1"
    case summer = "S2"
    case fall = "S3"
    case winter = "S4"
}

let startROCYear: Int = 101
let startYear: Int = startROCYear + 1911
let dateComponent = Calendar.current.dateComponents(in: .current, from: .init())
let endYear = dateComponent.year!

let start: DispatchTime = .now()
let requests: [URLRequest] = Array(startYear...endYear)
    .flatMap { year -> [String] in
        let rocYear = year - 1911
        return Season.allCases
            .map { season -> String in
                "\(rocYear)\(season.rawValue)"
            }
    }
    .map { season -> URLComponents  in
        var components: URLComponents = .init()
        components.scheme = "https"
        components.host = "plvr.land.moi.gov.tw"
        components.path = "/DownloadSeason"
        components.queryItems = [
            .init(name: "season", value: season),
            .init(name: "name", value: "zip"),
            .init(name: "fileName", value: "lvr_landtxt.zip")
        ]
        return components
    }
    .compactMap { component -> URL? in
        component.url
    }
    .map { url -> URLRequest in
        var request: URLRequest = .init(url: url)
        request.timeoutInterval = 300
        return request
    }

let group: DispatchGroup = .init()
requests.forEach { request in
    group.enter()
    URLSession.shared.dataTask(with: request) { data, resp, error in
        DispatchQueue.global().async {
            print("\(resp?.url?.absoluteString ?? "") - \(data?.count ?? 0)")
            group.leave()
        }        
    }.resume()
}
group.notify(queue: .global(), execute: {
    let end: DispatchTime = .now()
    let interval: Double = .init(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
    print("下載時間: \(interval) seconds")
})

