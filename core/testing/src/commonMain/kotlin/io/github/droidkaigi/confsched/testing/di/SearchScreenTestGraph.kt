package io.github.droidkaigi.confsched.testing.di

import dev.zacsweers.metro.Provider
import dev.zacsweers.metro.Provides
import io.github.droidkaigi.confsched.sessions.SearchScreenContext
import io.github.droidkaigi.confsched.testing.robot.search.SearchScreenRobot

interface SearchScreenTestGraph : SearchScreenContext.Factory {
    val searchScreenRobotProvider: Provider<SearchScreenRobot>

    @Provides
    fun provideSearchScreenContext(): SearchScreenContext {
        return createSearchScreenContext()
    }
}

fun createSearchScreenTestGraph(): SearchScreenTestGraph = createTestAppGraph()
