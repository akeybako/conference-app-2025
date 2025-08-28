@preconcurrency import Foundation
import Model
import UseCase
import shared

struct ProfileUseCaseImpl {
    // Note: Removed custom initializer to avoid breaking dependency injection
    // Migration is performed on first load() call instead
    
    func load() -> any AsyncSequence<Model.Profile?, Never> {
        print("[ProfileCardDebug] ProfileUseCaseImpl: load() called")
        
        // Perform migration on first load if needed
        Task {
            print("[ProfileCardDebug] ProfileUseCaseImpl: Starting migration task")
            await migrateProfileFromUserDefaultsToKMP()
            print("[ProfileCardDebug] ProfileUseCaseImpl: Migration task completed")
        }
        
        print("[ProfileCardDebug] ProfileUseCaseImpl: Getting profile flow from KMP")
        let flow = KMPDependencyProvider.shared.appGraph.profileRepository
            .profileFlow()
        
        print("[ProfileCardDebug] ProfileUseCaseImpl: Mapping profile flow")
        return flow.map { profileWithImages in
            print("[ProfileCardDebug] ProfileUseCaseImpl: Received profileWithImages, converting to iOS Profile")
            let iosProfile = Model.Profile(from: profileWithImages)
            print("[ProfileCardDebug] ProfileUseCaseImpl: Converted profile: \(iosProfile?.name ?? "nil")")
            return iosProfile
        }
    }

    func save(_ profile: Model.Profile) async {
        do {
            let kmpProfile = shared.Profile.create(from: profile)
            try await KMPDependencyProvider.shared.appGraph.profileRepository
                .save(profile: kmpProfile)
        } catch {
            // Profile save failed - error handling could be improved
        }
    }
}
