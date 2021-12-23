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
        URLSession.shared.dataTaskPublisher(for: url)
    }
    .receive(on: DispatchQueue.global())
    .sink(receiveCompletion: { completion in
        print(completion)
    }, receiveValue: { output in
        print(output.data.count)
    })
    .store(in: &cancellables)

// 調整每次下載一部份就好
