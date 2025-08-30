@preconcurrency import Foundation
import Model
import UseCase
import shared

struct ProfileUseCaseImpl {
    func load() -> any AsyncSequence<Model.Profile?, Never> {
        let profileDataStore = KMPDependencyProvider.shared.appGraph.profileDataStore
        let profileFlow = profileDataStore.getProfileOrNull()

        return profileFlow.map { kmpProfile in
            guard let kmpProfile = kmpProfile else {
                return nil
            }

            guard let url = URL(string: kmpProfile.link.isEmpty ? "https://example.com" : kmpProfile.link) else {
                return nil
            }

            return Model.Profile(
                name: kmpProfile.nickName,
                occupation: kmpProfile.occupation,
                url: url,
                image: Data(),  // TODO: Handle image data properly
                cardVariant: Model.ProfileCardVariant(from: kmpProfile.theme)
            )
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
