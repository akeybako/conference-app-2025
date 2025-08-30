import EventKit
import Foundation
import Model
import Observation
import Presentation

@MainActor
@Observable
final class TimetableDetailPresenter {
    struct Toast {
        var message: String
        var action: (title: String, handler: () -> Void)? = nil
    }

    let timetableItem: TimetableItemWithFavorite
    private let timetableProvider = TimetableProvider()
    private let eventStore: EKEventStore

    var isFavorite: Bool {
        timetableItem.isFavorited
    }

    var toast: Toast?

    init(timetableItem: TimetableItemWithFavorite) {
        self.timetableItem = timetableItem
        self.eventStore = EKEventStore()
    }

    func toggleFavorite() {
        timetableProvider.toggleFavorite(timetableItem)
        if !timetableItem.isFavorited {
            toast = Toast(message: "ブックマークに追加されました", action: ("一覧を見る", navigateToFavorite))
        }
    }

    func addToCalendar() {
        let status = EKEventStore.authorizationStatus(for: .event)

        switch status {
        case .notDetermined:
            eventStore.requestFullAccessToEvents { [weak self] granted, _ in
                guard let self = self else { return }
                Task { @MainActor in
                    if granted {
                        self.createCalendarEvent()
                    } else {
                        self.toast = Toast(message: "カレンダーへのアクセスが許可されていません")
                    }
                }
            }
        case .fullAccess, .writeOnly:
            createCalendarEvent()
        case .restricted, .denied:
            self.toast = Toast(message: "カレンダーへのアクセスが許可されていません")
        @unknown default:
            break
        }
    }

    private func createCalendarEvent() {
        let event = EKEvent(eventStore: eventStore)
        event.title = timetableItem.timetableItem.title.currentLangTitle
        event.startDate = timetableItem.timetableItem.startsAt
        event.endDate = timetableItem.timetableItem.endsAt
        event.location = timetableItem.timetableItem.room.name.currentLangTitle

        if let session = timetableItem.timetableItem as? TimetableItemSession {
            event.notes = session.description.currentLangTitle
        } else if let special = timetableItem.timetableItem as? TimetableItemSpecial {
            event.notes = special.description.currentLangTitle
        }

        event.calendar = eventStore.defaultCalendarForNewEvents

        do {
            try eventStore.save(event, span: .thisEvent)
            toast = Toast(message: "カレンダーに追加しました")
        } catch {
            toast = Toast(message: "カレンダーの追加に失敗しました")
        }
    }

    func shareSession() -> URL? {
        guard let url = URL(string: "https://droidkaigi.jp/2025/timetable/\(timetableItem.timetableItem.id.value)")
        else { return nil }
        return url
    }

    private func navigateToFavorite() {
        // TODO: Add logic to navigate to favorite screen
    }

    var isCancelledSession: Bool {
        if let session = timetableItem.timetableItem as? TimetableItemSession {
            return session.message != nil
        }
        return false
    }
}
