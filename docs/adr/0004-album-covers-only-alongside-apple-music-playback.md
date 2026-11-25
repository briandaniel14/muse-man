# Album covers only alongside Apple Music playback

Album covers from Apple Music appear only next to Apple Music playback of that Song: Apple's official "Listen on Apple Music" badge linking to the song, full songs for subscribers and previews for everyone else. The Developer Program License Agreement 3.3.6(D) and App Review Guideline 4.5.2(ii) allow cover art only in connection with music playback or playlists, and the Apple Music Identity Guidelines require Apple's own badge artwork, unaltered, and a link to Apple Music wherever it appears.

So a Song chosen from the Apple Music search on New Song keeps its Apple Music song (the catalogue id and its share URL), which syncs with the Song like its other details. The URL lets the badge open the song without a lookup; the id is what playback fetches the song by. A Song typed in by hand has none and shows no badge.

## Consequences

- The badge is the official en-us SVG from the Apple Marketing Toolbox, shipped unaltered in MuseManCore's resources. It's the black badge with its grey border, which works on light and dark backgrounds.
- Songs added before this change have no Apple Music song and aren't looked up again: they keep their cover, with no badge or playback bar beside it, until the Musician re-adds them.
- The cover mosaics on Collections and Practice Sessions are unchanged for now, pending a question to Apple's App Review about whether they're allowed.
- The two new Song fields reach the CloudKit development schema the same way the Song Note did, and the production schema only ever gains fields (ADR 0001).
