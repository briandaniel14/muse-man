# Apple Music badge, playback and previews

Researched 2026-11-25 for #46–#48 ([ADR 0004](../adr/0004-album-covers-only-alongside-apple-music-playback.md)). Sources are Apple's developer documentation, the Apple Marketing Toolbox and the Apple Music Identity Guidelines; the macOS behaviour was checked in the app with `mac-app`.

## Summary

- **Badge:** Apple's "Listen on Apple Music" artwork comes from the Marketing Toolbox API as SVG. Use it unaltered, always as a link to the song.
- **Opening a song:** MusicKit's `Song.url` is a `music.apple.com` share link. On macOS it opens the Music app, not the browser.
- **Full songs:** `ApplicationMusicPlayer` works on macOS 14+ and iOS; `SystemMusicPlayer` doesn't exist on macOS. `MusicSubscription.current.canPlayCatalogContent` says whether the Musician can play full songs.
- **Previews:** `Song.previewAssets?.first?.url` is a ~30-second AAC file, played with `AVPlayer`. A nil url means no preview.
- **Storefronts:** catalogue ids are per storefront. An id from one country's catalogue can 404 in another.

## Badge artwork

- The old host `tools.applemarketingtools.com` no longer resolves; `tools.applemediaservices.com` redirects to `toolbox.marketingtools.apple.com`.
- API: `https://toolbox.marketingtools.apple.com/api/v2/badges/listen-on-apple-music/<variant>/<lang>` returns `image/svg+xml`. Found through a Toolbox song page's Badges widget, e.g. https://toolbox.marketingtools.apple.com/en-us/apple-music/us/song/1517447333.

| variant | look |
|---|---|
| `badge` | black rounded rect, grey border, colour icon, white type; works on light and dark (the one muse-man ships) |
| `standard-black` / `standard-white` | lockup: colour icon with black or white type |
| `mono-black` / `mono-white` | all-black or all-white lockup |
| `compact` | small black "Apple Music" pill (en-us only) |

- SwiftUI can't render an SVG from a file URL; ship it in an `.xcassets` with Preserve Vector Data and load it with `Image(_:bundle: .module)`.

### Identity Guidelines

https://marketing.services.apple/apple-music-identity-guidelines (the old apple.com/itunes/marketing-on-music URL redirects there):

- Use only Apple's artwork; never alter, rotate, animate, shadow or glow it. The grey border is part of the badge.
- Online, every badge or lockup must link to Apple Music.
- One badge per communication, below or to the right of what it promotes, smaller than the main imagery.
- Clear space at least 1/10 of the badge's height; digital minimum 30 px high (compact: 12 px). Lockups: 1/4 clear space, 25 px minimum; never combine a lockup with a badge.

## Identity and opening a song

- `Song.id` is a `MusicItemID`; persist `id.rawValue`. Re-fetch with `MusicCatalogResourceRequest<Song>(matching: \.id, equalTo: MusicItemID(raw))`, which needs `MusicAuthorization` like search does. https://developer.apple.com/documentation/musickit/musicitemid
- `Song.url` has the shape `https://music.apple.com/<storefront>/album/<slug>/<albumID>?i=<songID>`. https://developer.apple.com/documentation/musickit/song/url
- Ids are per catalogue item and availability varies by storefront: a US id can return `MusicDataRequest.Error` 404 in `za`. Check an id in a storefront with `https://itunes.apple.com/lookup?id=<id>&country=<cc>`. The scratch store's sample Songs carry US ids, so outside the US they show the badge but get no playback bar; a Song added through New Song's search gets an id from the Musician's own storefront.

## Full-song playback

- `ApplicationMusicPlayer.shared`: iOS 15+, macOS 14+; doesn't touch the Music app's own state. https://developer.apple.com/documentation/musickit/applicationmusicplayer
- Set `queue = [song]`, then `try await play()`; `pause()`, `stop()`. https://developer.apple.com/documentation/musickit/musicplayer
- `playbackTime` is settable (seeks) but not observable: poll it. It can be NaN. Duration is `Song.duration`.
- `state.playbackStatus`: `.playing`, `.paused`, `.stopped`, `.interrupted`, `.seekingForward`, `.seekingBackward`. `state` is an `ObservableObject`, not `@Observable`.
- `try await MusicSubscription.current` → `canPlayCatalogContent`; `MusicSubscription.subscriptionUpdates` streams changes. https://developer.apple.com/documentation/musickit/musicsubscription

## Previews

- `Song.previewAssets: [PreviewAsset]?`, each with `url` (AAC `.m4a` on `audio-ssl.itunes.apple.com`) and `hlsURL`. They arrive with search and resource-request results. https://developer.apple.com/documentation/musickit/song/previewassets
- Play with `AVPlayer(url:)`; time from `currentTime()`, duration from `currentItem?.duration`, seek with `seek(to:)`, end via `AVPlayerItem.didPlayToEndTimeNotification`.
- Audio sessions don't stop one player when another starts on macOS, so the app's one `AudioPlayer` stops the others itself.

## App Review rules

From https://developer.apple.com/app-store/review/guidelines/#apple-music:

- 4.5.2(i): the Musician starts playback with standard controls; no gating behind payment or ads.
- 4.5.2(ii) and DPLA 3.3.6(D): cover art only in connection with playback or playlists.
- 5.2.5: wherever previews play, link to the song in Apple Music. Previews may not be used for their entertainment value.
