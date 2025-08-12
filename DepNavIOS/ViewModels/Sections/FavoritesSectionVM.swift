import Combine
import Foundation

@MainActor
final class FavoritesSectionVM: ObservableObject {
    @Published var favoriteItems: [InternalMarkerModel] = []
    @Published var isEmpty: Bool = true

    private let mapViewModel: MapViewModel
    private var cancellables = Set<AnyCancellable>()

    init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel

        mapViewModel.dbViewModel.$favoriteItems
            .sink { [weak self] items in
                guard let self else { return }
                self.isEmpty = items.isEmpty
                self.favoriteItems = items.compactMap { mapObject in
                    let desc = self.mapViewModel.getMapDescriptionByDepartment(department: mapObject.department)
                    return mapObject.toInternalMarkerModel(mapDescription: desc)
                }
            }
            .store(in: &cancellables)
    }

    func clearFavorites() { mapViewModel.dbViewModel.clearAllFavorites() }

    func remove(_ item: InternalMarkerModel) {
        if let obj = mapViewModel.dbViewModel.favoriteItems.first(where: { $0.objectTitle == item.title && $0.department == item.department }) {
            mapViewModel.removeFavoriteItem(obj)
        }
    }

    func select(_ item: InternalMarkerModel) { mapViewModel.selectSearchResult(item) }
}
