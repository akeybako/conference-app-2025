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

            // Load image data from file path - return nil if no valid image data
            guard !kmpProfile.imagePath.isEmpty else {
                return nil as Model.Profile?
            }

            let imageData = loadImageDataFromFile(kmpProfile.imagePath)
            guard !imageData.isEmpty else {
                return nil as Model.Profile?
            }

            return Model.Profile(from: kmpProfile, imageData: imageData)
        }
    }

    func save(_ profile: Model.Profile) async {
        do {
            let kmpProfile = shared.Profile(from: profile)
            try await KMPDependencyProvider.shared.appGraph.profileRepository.save(profile: kmpProfile)
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
