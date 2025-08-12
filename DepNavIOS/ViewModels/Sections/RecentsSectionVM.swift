import Combine
import Foundation

@MainActor
final class RecentsSectionVM: ObservableObject {
    @Published var recentItems: [InternalMarkerModel] = []
    @Published var isEmpty: Bool = true

    private let mapViewModel: MapViewModel
    private var cancellables = Set<AnyCancellable>()

    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel

        mapViewModel.dbViewModel.$historyItems
            .sink { [weak self] items in
                guard let self else { return }
                self.isEmpty = items.isEmpty
                self.recentItems = items.prefix(10).compactMap { mapObject in
                    let desc = self.mapViewModel.getMapDescriptionByDepartment(department: mapObject.department)
                    return mapObject.toInternalMarkerModel(mapDescription: desc)
                }
            }
            .store(in: &cancellables)
    }

    func clearHistory() {
        mapViewModel.dbViewModel.clearAllHistory()
    }

    func select(item: InternalMarkerModel) {
        // Find underlying MapObjectModel to keep single source of truth in DB/history
        if let origin = mapViewModel.dbViewModel.historyItems.first(where: { $0.objectTitle == item.title && $0.department == item.department }) {
            mapViewModel.selectHistoryItem(origin)
        } else {
            // fallback if not found in local cache
            mapViewModel.selectSearchResult(item)
        }
    }
}
