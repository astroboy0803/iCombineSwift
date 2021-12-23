import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

var cancellables: Set<AnyCancellable> = .init()

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

let workQueue: DispatchQueue = .global()
let start: DispatchTime = .now()

Array(startYear...endYear)
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
    .publisher
    .compactMap { components -> URL? in
        components.url
    }
    .flatMap { url -> URLSession.DataTaskPublisher in
        var request: URLRequest = .init(url: url)
        request.timeoutInterval = 300
        return URLSession.shared.dataTaskPublisher(for: request)
    }
    .receive(on: workQueue)
    .sink(receiveCompletion: { completion in
        let end: DispatchTime = .now()
        let interval: Double = .init(end.uptimeNanoseconds - start.uptimeNanoseconds) / 1_000_000_000
        print("下載時間: \(interval) seconds")
        print(completion)
    }, receiveValue: { output in
        print("\(output.response.url?.absoluteString ?? "") - \(output.data.count)")
    })
    .store(in: &cancellables)

// 調整每次下載一部份就好
