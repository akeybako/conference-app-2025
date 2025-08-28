import Dependencies
import Model
import Observation
import UseCase

@Observable
public final class ProfileProvider {
    @ObservationIgnored
    @Dependency(\.profileUseCase) private var profileUseCase

    @ObservationIgnored
    private var fetchProfile: Task<Void, Never>?

    public var isLoading: Bool = false
    public var profile: Profile?

    public init() {}

    @MainActor
    public func subscribeProfileIfNeeded() {
        print("[ProfileCardDebug] ProfileProvider: subscribeProfileIfNeeded() called")
        guard fetchProfile == nil else { 
            print("[ProfileCardDebug] ProfileProvider: fetchProfile already exists, returning")
            return 
        }

        print("[ProfileCardDebug] ProfileProvider: Setting isLoading = true")
        isLoading = true

        print("[ProfileCardDebug] ProfileProvider: Starting profile loading task")
        self.fetchProfile = Task {
            print("[ProfileCardDebug] ProfileProvider: Inside profile loading task")
            do {
                for await profile in profileUseCase.load() {
                    print("[ProfileCardDebug] ProfileProvider: Received profile: \(profile?.name ?? "nil")")
                    self.profile = profile
                    self.isLoading = false
                }
            } catch {
                print("[ProfileCardDebug] ProfileProvider: Error loading profile: \(error)")
                self.isLoading = false
            }
        }
        print("[ProfileCardDebug] ProfileProvider: Task created")
    }

    @MainActor
    public func saveProfile(_ profile: Profile) {
        Task {
            await profileUseCase.save(profile)
        }
    }
}
