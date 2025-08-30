import FavoriteFeature
import Model
import Observation
import shared

@MainActor
@Observable
final class KMPFavoriteScreenPresenter: @preconcurrency FavoritePresenterProtocol {

    @ObservationIgnored
    private var fetchTask: Task<Void, Never>?
    @ObservationIgnored
    private let events: SkieSwiftMutableSharedFlow<any shared.FavoritesFavoritesScreenEvent> =
        favoritesScreenEventFlow()

    var favoriteTimetableItems: [TimetableTimeGroupItems] = .init()
    var dateFilter: Model.FavoriteDateFilter = .all

    func loadInitial() {
        guard fetchTask == nil else {
            return
        }

        self.fetchTask = Task {
            let uiStateStateFlow = favoritesScreenPresenterStateFlow(
                iosAppGraph: KMPDependencyProvider.shared.appGraph,
                eventFlow: SkieSwiftMutableSharedFlow(events)
            )

            for await state in uiStateStateFlow {
                switch onEnum(of: state.timetableContentState) {
                case .empty: favoriteTimetableItems = []
                case .favoriteList(let list): favoriteTimetableItems = mapTimetableTimeGroupItems(list)
                }
                dateFilter = mapDateFilter(state.filterState)
            }
        }
    }

    func toggleFavorite(_ item: Model.TimetableItemWithFavorite) {
        _ = events.tryEmit(
            value: FavoritesFavoritesScreenEventBookmark(id: shared.TimetableItemId(value: item.id.value)))
    }

    private func mapDateFilter(_ filterState: shared.FavoritesFavoritesScreenUiState.FilterState) -> FavoriteDateFilter
    {
        if filterState.allFilterSelected { return .all }
        if filterState.isDay1FilterSelected { return .day1 }
        if filterState.isDay2FilterSelected { return .day2 }
        return .all
    }

    private func mapTimetableTimeGroupItems(
        _ list: shared.FavoritesFavoritesScreenUiStateTimetableContentStateFavoriteList
    ) -> [TimetableTimeGroupItems] {
        return list.timetableItemMap.map { key, value in
            .init(
                startsTimeString: key.startTimeString,
                endsTimeString: key.endTimeString,
                items: value.map { item in
                    return .init(
                        timetableItem: mapTimetableItem(item),
                        isFavorited: true
                    )
                }
            )
        }
    }

    private func mapTimetableItem(_ item: shared.TimetableItem) -> any Model.TimetableItem {
        switch onEnum(of: item) {
        case .session(let sessionItem):
            return Model.TimetableItemSession(from: sessionItem)
        case .special(let specialItem):
            return Model.TimetableItemSpecial(from: specialItem)
        }
    }
}
