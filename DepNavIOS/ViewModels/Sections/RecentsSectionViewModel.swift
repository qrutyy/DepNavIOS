//
//  RecentsSectionViewModel.swift
//  DepNavIOS
//
//  Created by Mikhail Gavrilenko on 05.08.2025.
//

import Combine
import Foundation

protocol RecentsViewModelDelegate: AnyObject {
    func recentsViewModel(didSelectHistoryItem item: MapObjectModel)
}

@MainActor
class RecentsViewModel: ObservableObject {
    @Published var recentItems: [InternalMarkerModel] = []
    @Published var isHistoryEmpty: Bool = true

    weak var delegate: RecentsViewModelDelegate?

    // dependencies for db handling
    private let historyService: HistoryServiceProtocol
    private let mapDescriptionProvider: (String) -> MapDescription?
    private var cancellables = Set<AnyCancellable>()

    init(historyService: HistoryServiceProtocol, mapDescriptionProvider: @escaping (String) -> MapDescription?) {
        self.historyService = historyService
        self.mapDescriptionProvider = mapDescriptionProvider

        historyService.historyItemsPublisher
            .sink { [weak self] historyItems in
                guard let self = self else { return }
                self.isHistoryEmpty = historyItems.isEmpty
                self.recentItems = historyItems.prefix(10).compactMap { mapObject in
                    guard let mapDescription = self.mapDescriptionProvider(mapObject.department) else {
                        print("Falied to get map description for \(mapObject.department)")
                        return nil
                    }
                    return mapObject.toInternalMarkerModel(mapDescription: mapDescription)
                }
            }
            .store(in: &cancellables)
    }

    func clearHistory() {
        historyService.clearAllHistory()
    }

    func selectItem(_ item: InternalMarkerModel) {
        if let originalItem = historyService.findHistoryItem(byId: item.id) {
            delegate?.recentsViewModel(didSelectHistoryItem: originalItem)
        }
    }
}

protocol HistoryServiceProtocol {
    var historyItemsPublisher: AnyPublisher<[MapObjectModel], Never> { get }
    func clearAllHistory()
    func findHistoryItem(byId: String) -> MapObjectModel?
}
