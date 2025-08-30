@preconcurrency import Foundation
import Model
import UseCase
import shared

struct ProfileUseCaseImpl {
    func load() -> any AsyncSequence<Model.Profile?, Never> {
        // Now that we have proper image file saving, we can use ProfileRepository.profileFlow()
        // which provides ProfileWithImages including the image data
        let profileRepository = KMPDependencyProvider.shared.appGraph.profileRepository
        let profileFlow = profileRepository.profileFlow()

        return profileFlow.map { profileWithImages in
            return Model.Profile(from: profileWithImages)
        }
    }

    func save(_ profile: Model.Profile) async {
        do {
            let kmpProfile = shared.Profile.createKmpProfile(from: profile)
            let profileDataStore = KMPDependencyProvider.shared.appGraph.profileDataStore
            try await profileDataStore.saveProfile(profile: kmpProfile)
        } catch {
            print("Failed to save profile: \(error)")
        }
    }
}
