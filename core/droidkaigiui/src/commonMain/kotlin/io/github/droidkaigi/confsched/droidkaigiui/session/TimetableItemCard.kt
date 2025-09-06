package io.github.droidkaigi.confsched.droidkaigiui.session

import androidx.compose.foundation.background
import androidx.compose.foundation.border
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Favorite
import androidx.compose.material.icons.filled.Info
import androidx.compose.material.icons.outlined.FavoriteBorder
import androidx.compose.material3.Icon
import androidx.compose.material3.LocalMinimumInteractiveComponentSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
import androidx.compose.runtime.Composable
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.remember
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.hapticfeedback.HapticFeedbackType
import androidx.compose.ui.platform.LocalHapticFeedback
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.SemanticsPropertyKey
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.SpanStyle
import androidx.compose.ui.text.buildAnnotatedString
import androidx.compose.ui.text.intl.Locale
import androidx.compose.ui.text.style.TextDecoration
import androidx.compose.ui.text.toUpperCase
import androidx.compose.ui.unit.dp
import io.github.droidkaigi.confsched.designsystem.theme.LocalRoomTheme
import io.github.droidkaigi.confsched.designsystem.theme.ProvideRoomTheme
import io.github.droidkaigi.confsched.droidkaigiui.DroidkaigiuiRes
import io.github.droidkaigi.confsched.droidkaigiui.KaigiPreviewContainer
import io.github.droidkaigi.confsched.droidkaigiui.SubcomposeAsyncImage
import io.github.droidkaigi.confsched.droidkaigiui.bookmarked
import io.github.droidkaigi.confsched.droidkaigiui.component.OutlinedToolTip
import io.github.droidkaigi.confsched.droidkaigiui.component.RoomToolTip
import io.github.droidkaigi.confsched.droidkaigiui.extension.icon
import io.github.droidkaigi.confsched.droidkaigiui.extension.roomTheme
import io.github.droidkaigi.confsched.droidkaigiui.not_bookmarked
import io.github.droidkaigi.confsched.model.sessions.TimetableItem
import io.github.droidkaigi.confsched.model.sessions.TimetableSpeaker
import io.github.droidkaigi.confsched.model.sessions.fake
import org.jetbrains.compose.resources.stringResource
import org.jetbrains.compose.ui.tooling.preview.Preview

const val TimetableItemCardTestTag = "TimetableItemCard"
const val TimetableItemCardTitleTextTestTag = "TimetableItemCardTitleText"
const val TimetableItemCardBookmarkButtonTestTag = "TimetableItemCardBookmarkButton"
val TimetableItemCardSemanticsKey = SemanticsPropertyKey<TimetableItem>("TimetableItem")

@Composable
fun TimetableItemCard(
    timetableItem: TimetableItem,
    isBookmarked: Boolean,
    isDateTagVisible: Boolean,
    highlightWord: String,
    onBookmarkClick: () -> Unit,
    onTimetableItemClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val haptic = LocalHapticFeedback.current

    ProvideRoomTheme(timetableItem.room.roomTheme) {
        Row(
            verticalAlignment = Alignment.Top,
            modifier = modifier
                .testTag(TimetableItemCardTestTag)
                .semantics {
                    this[TimetableItemCardSemanticsKey] = timetableItem
                }
                .clip(RoundedCornerShape(16.dp))
                .clickable { onTimetableItemClick() }
                .background(Color.Transparent)
                .fillMaxWidth()
                .border(1.dp, MaterialTheme.colorScheme.outlineVariant, RoundedCornerShape(16.dp))
                .padding(
                    top = TimetableItemCardDefaults.tagRowTopPadding,
                    bottom = TimetableItemCardDefaults.contentPadding,
                    start = TimetableItemCardDefaults.contentPadding,
                )
                .testTag(TimetableItemCardTestTag),
        ) {
            Column(
                verticalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier
                    .weight(1f)
                    .padding(top = TimetableItemCardDefaults.rippleTopPadding),
            ) {
                FlowRow(
                    horizontalArrangement = Arrangement.spacedBy(4.dp),
                    verticalArrangement = Arrangement.spacedBy(4.dp),
                    itemVerticalAlignment = Alignment.CenterVertically,
                ) {
                    RoomToolTip(
                        icon = timetableItem.room.icon,
                        text = timetableItem.room.name.currentLangTitle.toUpperCase(Locale.current),
                        color = LocalRoomTheme.current.primaryColor,
                    )
                    timetableItem.language.labels.forEach { label ->
                        OutlinedToolTip(label)
                    }
                    if (isDateTagVisible) {
                        timetableItem.day?.let {
                            OutlinedToolTip("${it.month}/${it.dayOfMonth}")
                        }
                    }
                }
                TimetableItemTitle(timetableItem.title.currentLangTitle, highlightWord)
                Column(
                    verticalArrangement = Arrangement.spacedBy(4.dp),
                ) {
                    timetableItem.speakers.forEach { speaker ->
                        TimetableItemSpeaker(speaker)
                    }
                }
                timetableItem.message?.let { errorMessage ->
                    Row(
                        modifier = Modifier
                            .padding(top = 8.dp),
                        horizontalArrangement = Arrangement.spacedBy(8.dp),
                        verticalAlignment = Alignment.CenterVertically,
                    ) {
                        Icon(
                            imageVector = Icons.Filled.Info,
                            contentDescription = null,
                            tint = MaterialTheme.colorScheme.error,
                            modifier = Modifier.size(TimetableItemCardDefaults.errorIconSize),
                        )
                        Text(
                            text = errorMessage.currentLangTitle,
                            style = MaterialTheme.typography.bodySmall,
                            color = MaterialTheme.colorScheme.error,
                        )
                    }
                }
            }

            // remove top padding
            CompositionLocalProvider(LocalMinimumInteractiveComponentSize provides 0.dp) {
                FavoriteButton(
                    isBookmarked = isBookmarked,
                    onClick = {
                        if (!isBookmarked) {
                            haptic.performHapticFeedback(HapticFeedbackType.LongPress)
                        }
                        onBookmarkClick()
                    },
                )
            }
        }
    }
}

private object TimetableItemCardDefaults {
    // Magic number to top-align TimetableItemTagRow with FavoriteButton.
    val rippleTopPadding = 7.dp
    val contentPadding = 16.dp
    val tagRowTopPadding = contentPadding - rippleTopPadding
    val errorIconSize = 24.dp
}

@Composable
private fun TimetableItemTitle(
    title: String,
    highlightWord: String,
) {
    val highlightBackgroundColor = MaterialTheme.colorScheme.surfaceTint.copy(alpha = 0.14f)
    val highlightedTitle = remember(
        title,
        highlightBackgroundColor,
        highlightWord,
    ) {
        buildAnnotatedString {
            append(title)

            if (highlightWord.isEmpty()) return@buildAnnotatedString

            val highlightRanges = mutableListOf<IntRange>()
            var startIndex = 0
            while (true) {
                startIndex = title.indexOf(
                    string = highlightWord,
                    startIndex = startIndex,
                    ignoreCase = true,
                )
                if (startIndex == -1) {
                    break
                } else {
                    highlightRanges += IntRange(
                        startIndex,
                        startIndex + highlightWord.length,
                    )
                    startIndex += highlightWord.length
                }
            }

            val highlightStyle = SpanStyle(
                textDecoration = TextDecoration.Underline,
                background = highlightBackgroundColor,
            )

            highlightRanges.forEach { range ->
                addStyle(
                    style = highlightStyle,
                    start = range.first,
                    end = range.last,
                )
            }
        }
    }

    Text(
        modifier = Modifier.testTag(TimetableItemCardTitleTextTestTag),
        text = highlightedTitle,
        style = MaterialTheme.typography.titleLarge,
    )
}

@Composable
private fun FavoriteButton(
    isBookmarked: Boolean,
    onClick: () -> Unit,
) {
    TextButton(
        onClick = onClick,
        modifier = Modifier
            .testTag(TimetableItemCardBookmarkButtonTestTag),
    ) {
        if (isBookmarked) {
            Icon(
                Icons.Filled.Favorite,
                contentDescription = stringResource(DroidkaigiuiRes.string.bookmarked),
                tint = LocalRoomTheme.current.primaryColor,
            )
        } else {
            Icon(
                Icons.Outlined.FavoriteBorder,
                contentDescription = stringResource(DroidkaigiuiRes.string.not_bookmarked),
                tint = LocalRoomTheme.current.primaryColor,
            )
        }
    }
}

@Composable
private fun TimetableItemSpeaker(
    speaker: TimetableSpeaker,
    modifier: Modifier = Modifier,
) {
    Row(
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.spacedBy(8.dp),
        modifier = modifier,
    ) {
        SubcomposeAsyncImage(
            model = speaker.iconUrl,
            contentDescription = null,
            modifier = Modifier
                .width(32.dp)
                .height(32.dp)
                .clip(CircleShape)
                .border(
                    width = 1.dp,
                    color = MaterialTheme.colorScheme.outline,
                    shape = CircleShape,
                ),
        )
        Text(
            text = speaker.name,
            style = MaterialTheme.typography.titleSmall,
            color = MaterialTheme.colorScheme.onSurfaceVariant,
            modifier = Modifier
                .align(Alignment.CenterVertically),
        )
    }
}

@Preview
@Composable
private fun TimetableItemCardPreview() {
    KaigiPreviewContainer {
        TimetableItemCard(
            timetableItem = TimetableItem.Session.fake().copy(
                message = null,
            ),
            isBookmarked = false,
            isDateTagVisible = false,
            highlightWord = "",
            onBookmarkClick = {},
            onTimetableItemClick = {},
        )
    }
}

@Preview
@Composable
private fun TimetableItemCardPreview_WithError() {
    KaigiPreviewContainer {
        TimetableItemCard(
            timetableItem = TimetableItem.Session.fake(),
            isBookmarked = false,
            isDateTagVisible = false,
            highlightWord = "",
            onBookmarkClick = {},
            onTimetableItemClick = {},
        )
    }
}

@Preview
@Composable
private fun FavoriteButton() {
    KaigiPreviewContainer {
        ProvideRoomTheme(TimetableItem.Session.fake().room.roomTheme) {
            FavoriteButton(
                isBookmarked = false,
                onClick = {},
            )
        }
    }
}

@Preview
@Composable
private fun FavoriteButton_Bookmarked() {
    KaigiPreviewContainer {
        ProvideRoomTheme(TimetableItem.Session.fake().room.roomTheme) {
            FavoriteButton(
                isBookmarked = true,
                onClick = {},
            )
        }
    }
}

@Preview
@Composable
private fun TimetableItemTitlePreview() {
    KaigiPreviewContainer {
        TimetableItemTitle(
            title = "This is a sample title",
            highlightWord = "sample",
        )
    }
}

@Preview
@Composable
private fun TimetableItemTitlePreview_NoHighlight() {
    KaigiPreviewContainer {
        TimetableItemTitle(
            title = "This is a sample title",
            highlightWord = "example",
        )
    }
}
