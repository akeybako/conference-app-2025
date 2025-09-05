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
                return nil as Model.Profile?
            }

            guard let url = URL(string: kmpProfile.link.isEmpty ? "https://example.com" : kmpProfile.link) else {
                return nil as Model.Profile?
            }

            // Load image data from file path
            let imageData: Data
            if !kmpProfile.imagePath.isEmpty {
                imageData = loadImageDataFromFile(kmpProfile.imagePath)
            } else {
                imageData = Data()
            }

            return Model.Profile(
                name: kmpProfile.nickName,
                occupation: kmpProfile.occupation,
                url: url,
                image: imageData,
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

    private func loadImageDataFromFile(_ filePath: String) -> Data {
        let fileURL = URL(fileURLWithPath: filePath)
        do {
            return try Data(contentsOf: fileURL)
        } catch {
            print("Failed to load image from file \(filePath): \(error)")
            return Data()
        }
    }
}
