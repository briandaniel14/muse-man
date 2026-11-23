# Song lookup through Apple Music and ReccoBeats

Adding a Song searches the Apple Music catalogue with MusicKit for its title, artist and artwork, then looks up its key and tempo on ReccoBeats (`api.reccobeats.com/v1/audio-features?ids=<ISRC>`, no API key). No single free source has key, tempo and artwork, and the ISRC (the ID of one specific recording) is what joins the two: Apple gives it exactly for the chosen result, and ReccoBeats is keyed by it. A Song stores only its artwork URL, so CloudKit syncs a string, not an image.

Rejected: GetSongBPM (needs an API key with a backlink), iTunes Search plus Deezer for ISRCs (Deezer's catalogue has gaps, such as the studio "Wonderwall", and its field search returns nothing), MusicBrainz (rate-limits within a few requests), and Spotify audio features (closed to new apps).

## Consequences

- The MusicKit App Service must stay enabled for `com.briandaniel.museman` in the Apple Developer portal, and users grant Apple Music access once; no subscription is needed.
- ReccoBeats misses some recordings, such as remasters, so the lookup also sends the ISRCs of other versions of the same Song by the same artist from the search results, preferring the chosen one.
- ReccoBeats data is noisy (Wonderwall comes back at 174 BPM rather than 87, in D major or F♯ minor depending on the version), so key and tempo stay editable.
