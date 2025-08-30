import Dependencies
import Foundation
import Model
import UseCase

@MainActor
public final class StaffProvider {
    @Dependency(\.staffUseCase) private var staffUseCase

    public init() {}

    public func loadStaff() -> any AsyncSequence<[Staff], Never> {
        return staffUseCase.load()
    }
}
