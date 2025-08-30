import Dependencies
import Foundation
import Model
@testable import Presentation
import Testing
import UseCase

struct SponsorProviderTests {
    @MainActor
    @Test
    func loadSponsorCategoriesSuccess() async throws {
        let expectedSponsors = TestSponsorData.createMockSponsors()
        let provider = withDependencies {
            $0.sponsorsUseCase.load = {
                AsyncStream { continuation in
                    continuation.yield(expectedSponsors)
                    continuation.finish()
                }
            }
        } operation: {
            SponsorProvider()
        }

        await provider.loadSponsorCategories()
        
        #expect(provider.sponsors.count == 5)
        #expect(provider.sponsors[0].tier == .platinum)
        #expect(provider.sponsors[1].tier == .gold)
        #expect(provider.sponsors[2].tier == .silver)
        #expect(provider.sponsors[3].tier == .bronze)
        #expect(provider.sponsors[4].tier == .supporters)
    }
    
    @MainActor
    @Test
    func loadSponsorCategoriesGrouping() async throws {
        let sponsors = TestSponsorData.createMockSponsors()
        let provider = withDependencies {
            $0.sponsorsUseCase.load = {
                AsyncStream { continuation in
                    continuation.yield(sponsors)
                    continuation.finish()
                }
            }
        } operation: {
            SponsorProvider()
        }

        await provider.loadSponsorCategories()
        
        // Verify platinum category
        let platinumCategory = provider.sponsors.first { $0.tier == .platinum }
        #expect(platinumCategory != nil)
        #expect(platinumCategory?.name == "PLATINUM SPONSORS")
        #expect(platinumCategory?.sponsors.count == 2)
        #expect(platinumCategory?.sponsors.allSatisfy { $0.plan == .platinum } == true)
        
        // Verify gold category
        let goldCategory = provider.sponsors.first { $0.tier == .gold }
        #expect(goldCategory != nil)
        #expect(goldCategory?.name == "GOLD SPONSORS")
        #expect(goldCategory?.sponsors.count == 3)
        #expect(goldCategory?.sponsors.allSatisfy { $0.plan == .gold } == true)
        
        // Verify silver category
        let silverCategory = provider.sponsors.first { $0.tier == .silver }
        #expect(silverCategory != nil)
        #expect(silverCategory?.name == "SILVER SPONSORS")
        #expect(silverCategory?.sponsors.count == 2)
        #expect(silverCategory?.sponsors.allSatisfy { $0.plan == .silver } == true)
        
        // Verify bronze category
        let bronzeCategory = provider.sponsors.first { $0.tier == .bronze }
        #expect(bronzeCategory != nil)
        #expect(bronzeCategory?.name == "BRONZE SPONSORS")
        #expect(bronzeCategory?.sponsors.count == 1)
        #expect(bronzeCategory?.sponsors.allSatisfy { $0.plan == .bronze } == true)
        
        // Verify supporters category
        let supportersCategory = provider.sponsors.first { $0.tier == .supporters }
        #expect(supportersCategory != nil)
        #expect(supportersCategory?.name == "SUPPORTERS")
        #expect(supportersCategory?.sponsors.count == 2)
        #expect(supportersCategory?.sponsors.allSatisfy { $0.plan == .supporter } == true)
    }
    
    @MainActor
    @Test
    func loadSponsorCategoriesEmpty() async throws {
        let provider = withDependencies {
            $0.sponsorsUseCase.load = {
                AsyncStream { continuation in
                    continuation.yield([])
                    continuation.finish()
                }
            }
        } operation: {
            SponsorProvider()
        }

        await provider.loadSponsorCategories()
        
        #expect(provider.sponsors.isEmpty)
    }
    
    @MainActor
    @Test
    func loadSponsorCategoriesSkipsEmptyCategories() async throws {
        // Create sponsors with only platinum and bronze plans
        let sponsors = [
            TestSponsorData.createSponsor(id: "1", name: "Platinum Sponsor 1", plan: .platinum),
            TestSponsorData.createSponsor(id: "2", name: "Platinum Sponsor 2", plan: .platinum),
            TestSponsorData.createSponsor(id: "3", name: "Bronze Sponsor", plan: .bronze)
        ]
        
        let provider = withDependencies {
            $0.sponsorsUseCase.load = {
                AsyncStream { continuation in
                    continuation.yield(sponsors)
                    continuation.finish()
                }
            }
        } operation: {
            SponsorProvider()
        }

        await provider.loadSponsorCategories()
        
        #expect(provider.sponsors.count == 2)
        #expect(provider.sponsors[0].tier == .platinum)
        #expect(provider.sponsors[1].tier == .bronze)
        
        // Verify that gold, silver, and supporters categories are not present
        #expect(provider.sponsors.first { $0.tier == .gold } == nil)
        #expect(provider.sponsors.first { $0.tier == .silver } == nil)
        #expect(provider.sponsors.first { $0.tier == .supporters } == nil)
    }
    
    @MainActor
    @Test
    func loadSponsorCategoriesOrder() async throws {
        // Create sponsors in random order
        let sponsors = [
            TestSponsorData.createSponsor(id: "1", name: "Bronze Sponsor", plan: .bronze),
            TestSponsorData.createSponsor(id: "2", name: "Supporter", plan: .supporter),
            TestSponsorData.createSponsor(id: "3", name: "Platinum Sponsor", plan: .platinum),
            TestSponsorData.createSponsor(id: "4", name: "Silver Sponsor", plan: .silver),
            TestSponsorData.createSponsor(id: "5", name: "Gold Sponsor", plan: .gold)
        ]
        
        let provider = withDependencies {
            $0.sponsorsUseCase.load = {
                AsyncStream { continuation in
                    continuation.yield(sponsors)
                    continuation.finish()
                }
            }
        } operation: {
            SponsorProvider()
        }

        await provider.loadSponsorCategories()
        
        #expect(provider.sponsors.count == 5)
        // Verify categories are in the correct order
        #expect(provider.sponsors[0].tier == .platinum)
        #expect(provider.sponsors[1].tier == .gold)
        #expect(provider.sponsors[2].tier == .silver)
        #expect(provider.sponsors[3].tier == .bronze)
        #expect(provider.sponsors[4].tier == .supporters)
    }
    
    @MainActor
    @Test
    func loadSponsorCategoriesMultipleUpdates() async throws {
        let firstBatch = [
            TestSponsorData.createSponsor(id: "1", name: "Initial Sponsor", plan: .gold)
        ]
        
        let secondBatch = [
            TestSponsorData.createSponsor(id: "2", name: "Updated Sponsor 1", plan: .platinum),
            TestSponsorData.createSponsor(id: "3", name: "Updated Sponsor 2", plan: .gold)
        ]
        
        let provider = withDependencies {
            $0.sponsorsUseCase.load = {
                AsyncStream { continuation in
                    continuation.yield(firstBatch)
                    continuation.yield(secondBatch)
                    continuation.finish()
                }
            }
        } operation: {
            SponsorProvider()
        }

        await provider.loadSponsorCategories()
        
        // Should have the latest update (secondBatch)
        #expect(provider.sponsors.count == 2)
        #expect(provider.sponsors[0].tier == .platinum)
        #expect(provider.sponsors[0].sponsors.count == 1)
        #expect(provider.sponsors[1].tier == .gold)
        #expect(provider.sponsors[1].sponsors.count == 1)
    }
}

enum TestSponsorData {
    static func createMockSponsors() -> [Sponsor] {
        [
            createSponsor(id: "1", name: "Platinum Sponsor 1", plan: .platinum),
            createSponsor(id: "2", name: "Platinum Sponsor 2", plan: .platinum),
            createSponsor(id: "3", name: "Gold Sponsor 1", plan: .gold),
            createSponsor(id: "4", name: "Gold Sponsor 2", plan: .gold),
            createSponsor(id: "5", name: "Gold Sponsor 3", plan: .gold),
            createSponsor(id: "6", name: "Silver Sponsor 1", plan: .silver),
            createSponsor(id: "7", name: "Silver Sponsor 2", plan: .silver),
            createSponsor(id: "8", name: "Bronze Sponsor", plan: .bronze),
            createSponsor(id: "9", name: "Supporter 1", plan: .supporter),
            createSponsor(id: "10", name: "Supporter 2", plan: .supporter)
        ]
    }
    
    static func createSponsor(
        id: String,
        name: String,
        plan: SponsorPlan
    ) -> Sponsor {
        Sponsor(
            id: id,
            name: name,
            logoUrl: URL(string: "https://example.com/logo-\(id).png")!,
            websiteUrl: URL(string: "https://example.com/sponsor-\(id)")!,
            plan: plan
        )
    }
}