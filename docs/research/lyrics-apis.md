# Lyrics APIs for muse-man

Researched 2026-11-24. Sources are official docs, terms pages, developer portals and source repos. Live requests were made on that date where they needed no key or sign-up.

## Summary

**Question:** Which API could let muse-man show a Song's lyrics, given that a Song already has a title, an artist, a duration and an ISRC from MusicKit ([ADR 0003](../adr/0003-song-lookup-via-musickit-and-reccobeats.md))? Would the API's licence let the lyrics sync through CloudKit with the Song, or only be fetched when they're shown?

**Findings:**

- **Apple** has no public way to get lyrics text. MusicKit and the Apple Music API only say whether a song *has* lyrics.
- **LRCLIB** is the only source that is free, keyless and reliable. It worked for Wonderwall and returned plain and time-synced lyrics. Its lyrics are crowd-sourced, though, not licensed from publishers, and it publishes no terms of use.
- **Musixmatch** is the one licensed API you can sign up for yourself. It needs a key and costs at least $49/month for plain lyrics, or $199/month for time-synced lyrics. Only the Enterprise plan (from $2,000/month) lets you cache lyrics. That rules out storing them on a Song in CloudKit on every self-serve plan.
- **Genius**, **lyrics.ovh** and **LyricFind** are not usable: Genius has no documented lyrics text and bans scraping, lyrics.ovh scrapes other sites, and LyricFind only does business-to-business deals.

**Recommendation:** If lyrics go ahead, use **LRCLIB**:

- Fetch on demand, matching by title, artist, album and duration (it can't look up by ISRC).
- Send an identifying `User-Agent`.
- Keep the lyrics on the device instead of syncing them to CloudKit.

**The main trade-off** is cost and friction against legal footing. LRCLIB is free and fits how the app already looks songs up. But nothing grants a licence to the lyrics themselves, so App Review guideline 5.2.1 ("Don't use protected third-party material such as … copyrighted works … without permission") is a real risk. Musixmatch is the licensed alternative, at $199/month or more, with attribution and view-tracking rules.

A third option needs no API at all: let the Musician paste or type their own lyrics into the Song. Text they enter is their own content, so syncing it through CloudKit raises no licence question.

**The situation:** Every free source is either unlicensed (LRCLIB) or scrapes other sites (lyrics.ovh). The only licensed self-serve source is paid, and none of its self-serve plans allow caching.

**The options:**

- **Option A, LRCLIB on demand:** free and keyless, with synced lyrics and good coverage. The cost is App Review risk under 5.2.1/5.2.2 and no licence for the lyric text. Sharing lyrics into a Space via CloudKit would make that risk worse.
- **Option B, Musixmatch Grow:** licensed lyrics with time sync and an "App Store certificate". The cost is $199/month, a secret API key, the "powered by" badge, the copyright line and view tracking. It also can't be stored or synced.
- **Option C, lyrics the Musician enters:** no API, no licence question, and it syncs and shares freely through CloudKit. The cost is manual entry for every Song.

## Comparison

| Source | Auth | Cost / limits | Lookup keys | ISRC? | Synced? | Wonderwall (2026-11-24) | Store / sync allowed? | Attribution | Licensed? |
|---|---|---|---|---|---|---|---|---|---|
| Apple MusicKit / Apple Music API | Developer token (already in app) | Free | Catalog ID | Has `isrc` | n/a | `hasLyrics` flag only, no text | n/a | n/a | n/a (no public lyrics) |
| ShazamKit | Entitlement | Free | Audio signature | Returns `isrc` | n/a | No lyrics property | n/a | n/a | n/a |
| LRCLIB | None (optional app ID) | Free; ~45–90 req/min per IP anonymous | title + artist (+ album, duration ±2 s), free-text search, LRCLIB ID | No | Yes: LRC per line, some word-level | 200, plain + synced + word sync | No terms published | None stated | No (crowd-sourced) |
| Musixmatch | API key | No free plan listed; $49 / $199 / $499 per month, Enterprise from $2k | ISRC, title + artist, Spotify/iTunes IDs | Yes | Grow ($199) and up | Not tested (needs key; keyless call returns 401) | Caching only on Enterprise | `lyrics_copyright`, "powered by" badge with backlink, tracking pixel | Yes |
| Genius | OAuth / client token | Commercial use needs a licence | Search `q`, song ID | Not documented | No | Not tested (keyless call returns 401) | n/a | n/a | No lyrics text documented; scraping banned |
| lyrics.ovh | None | Free, no stated limits | artist + title in path | No | No | 200, plain text | No terms | None | No (scrapes other sites) |
| LyricFind | Contract | B2B, by enquiry | Not public | Not public | Static, line and word sync | Not tested | By contract | By contract | Yes |

## Apple MusicKit / Apple Music API

- **No public lyrics.** MusicKit's `Song.hasLyrics` is documented as "A Boolean value that indicates whether the song has lyrics available in the catalog" ([MusicKit hasLyrics](https://developer.apple.com/documentation/musickit/song/haslyrics)). Nothing in MusicKit returns the text.
- **The Apple Music API is the same.** Its `Songs.Attributes` list `hasLyrics` and `isrc` but no lyrics field ([Songs.Attributes](https://developer.apple.com/documentation/applemusicapi/songs/attributes-data.dictionary)). Its `Songs.Relationships` are albums, artists, composers, genres, library, music-videos and station, with no lyrics relationship ([Songs.Relationships](https://developer.apple.com/documentation/applemusicapi/songs/relationships-data.dictionary)).
- **Apple's own answer.** On the developer forums an Apple Frameworks Engineer accepted "Lyrics are not available, via MusicKit" as "exactly right". They asked developers to file Feedback Assistant requests, "to see if we might be allowed to expose lyrics in the future" ([forum thread 698127](https://developer.apple.com/forums/thread/698127), Jan–Feb 2022). WWDC26's MusicKit session, "Integrate MusicKit into your app", is listed with no lyrics announcement in its description ([WWDC26 session 254](https://developer.apple.com/videos/play/wwdc2026/254/)). I did not watch the full session.
- **Private endpoint.** A private `/syllable-lyrics` endpoint returning TTML exists. The MusanovaKit project, which wraps it, says it needs a "privileged developer token". Its README warns: "Shipping these APIs inside production software is likely to violate Apple's terms" and "Do not submit apps that rely on this package to the App Store" ([MusanovaKit README](https://github.com/rryam/MusanovaKit)). It is not an option for muse-man.
- **A useful side effect.** `hasLyrics` could decide whether to offer a lyrics action at all, but only if Apple's catalogue and the chosen lyrics source cover the same songs.

## ShazamKit

- **No lyrics.** `SHMediaItem` exposes title, subtitle, artist, artwork URL, video URL, genres, explicit flag, creation date, `isrc`, ID, Apple Music URL/ID, Shazam ID and web URL ([SHMediaItem](https://developer.apple.com/documentation/shazamkit/shmediaitem)).
- **Unanswered question.** A 2024 forum question asking how to show synced lyrics after a Shazam match has no reply ([forum thread 748531](https://developer.apple.com/forums/thread/748531)).

## LRCLIB (lrclib.net)

**Access and rate limits**

- **Auth:** none. "No API key is required, and anonymous API access remains available" ([LRCLIB API docs](https://lrclib.net/docs.md)).
- **Client identification:** clients must send a `User-Agent` with the app name, version and a homepage link or email.
- **Optional registration:** registering adds a public `Lrclib-App-Id` header, safe to ship in a client, and gives "higher rate limits, a shareable API authorization document (useful when submitting to app review)" ([docs, Client identification](https://lrclib.net/docs#implementation-requirements-client-identification)).
- **Rate limits:** approximate, and "not part of the API contract" ([docs, Rate Limiting](https://lrclib.net/docs#implementation-requirements-rate-limiting)):

  | Client | Allowance |
  |---|---|
  | Generic client | ~45 req/min per IP |
  | Identified `User-Agent` | ~90 req/min |
  | Registered client-side app | ~180 req/min, plus an app-wide ~6,000 req/min |

  A `429` comes with a `Retry-After` header, which clients "must honor".
- **Cost:** free. The service describes itself as "a free, open lyrics database" ([llms.txt](https://lrclib.net/llms.txt)). The server code is MIT-licensed ([tranxuanthang/lrclib](https://github.com/tranxuanthang/lrclib)).

**Lookup**

- **Exact match:** `GET /api/get?track_name&artist_name[&album_name][&duration]`. Duration is "crucial": a match needs to be within ±2 seconds ([docs, Get lyrics](https://lrclib.net/docs#get-lyrics-with-a-tracks-signature)).
- **Other endpoints:** `GET /api/get/{id}`, `GET /api/search` (up to 20 results, no pagination), and a beta `GET /api/v2/search` that returns availability flags without the lyrics.
- **No ISRC parameter** on any endpoint.
- **Misses:** a 404 may be "picked up by the background lyrics fetching service and may become available in a later request".

**Format**

- **Fields:** `plainLyrics`, `syncedLyrics` (LRC with per-line timestamps), `lyricsfile` (YAML, word-level timings when `hasWordSync` is true) and `instrumental` ([docs, Lyrics record fields](https://lrclib.net/docs#lyrics-record-fields)).

**Wonderwall test (2026-11-24)**

- **Exact match:** `GET /api/get?track_name=Wonderwall&artist_name=Oasis&album_name=(What's the Story) Morning Glory?&duration=258` returned 200. The record was ID 16226, duration 259 s, with plain lyrics, LRC-synced lyrics (`[00:23.09] Today is gonna be the day…`) and `hasWordSync: true`. Leaving out the album with `duration=259` also matched.
- **Search:** `/api/search?track_name=Wonderwall&artist_name=Oasis` returned 20 records across the album, its remaster and compilations, all with synced lyrics.
- **No key, no sign-up.**

**Licensing and terms**

- **No terms published.** The site is a JavaScript app, and its API docs, `llms.txt` and full docs contain no terms of use, licence for the lyric text, attribution requirement, or rule on caching or storage. They only mention "copyright violation" as a reason to flag a record ([docs, Flag a lyrics](https://lrclib.net/docs#flag-a-lyrics)).
- **Crowd-sourced content.** Lyrics are crowd-contributed through an anonymous `POST /api/publish` ([docs, Publish](https://lrclib.net/docs#publish-a-new-lyrics)). Nothing says they are licensed from publishers.
- **Commercial use is unanswered.** Two open GitHub issues ask whether lyrics may be cached in an app's own database and used commercially. Neither has an answer from the maintainer ([#111](https://github.com/tranxuanthang/lrclib/issues/111), opened 2026-07-03; [#134](https://github.com/tranxuanthang/lrclib/issues/134), opened 2026-10-25).

**App Store**

- **5.2.2 may be covered.** The optional "API authorization document" is meant for guideline 5.2.2: "ensure that you are specifically permitted to do so under the service's terms of use. Authorization must be provided upon request" ([App Review Guidelines 5.2](https://developer.apple.com/app-store/review/guidelines/#intellectual-property)).
- **5.2.1 is not.** My inference: LRCLIB can authorise use of its service, but it does not own the lyrics, so it cannot answer guideline 5.2.1 (copyrighted works need permission).

**Storing and syncing**

- **Nothing forbids it, but nothing allows it either.** If lyrics were stored on a Song, ADR 0002 means they would be copied to every Musician in a Shared Space ([ADR 0002](../adr/0002-shared-spaces-and-private-practice-history.md)). That is redistribution, not just display.

## Musixmatch

**Access**

- **Auth:** an `apikey` query parameter on every call, "a mandatory parameter for most API calls … should be kept secret" ([Getting started](https://docs.musixmatch.com/getting-started)).
- **Keyless test:** a keyless `matcher.lyrics.get` for Wonderwall returned `status_code: 401` (2026-11-24).
- **Sign-up:** the developer portal's sign-up page now says "Signup disabled" ([developer.musixmatch.com/signup](https://developer.musixmatch.com/signup)). Sign-up goes through the pricing page.

**Pricing**

[Musixmatch Pro API pricing](https://www.musixmatch.com/pro/api/pricing): the page renders with JavaScript, so the figures below were read from the plan data in its script bundle on 2026-11-24.

| Plan | Price | Calls per day | Includes | Not included |
|---|---|---|---|---|
| Basic | $49/mo | 5k total, 500 lyrics | Music metadata, static lyrics | Time-synced lyrics, lyrics caching |
| Grow | $199/mo | 20k total, 2k lyrics | Basic, time-synced lyrics, "App Store certificate" | Lyrics caching |
| Scale | $499/mo | 100k total, 10k lyrics | Grow | Lyrics caching |
| Enterprise | Custom, "starting from $2,000/mo" | Custom | Scale, "Lyrics caching" ("Cache lyrics (licensed only)") | |

**Free tier and 30% truncation: not confirmed.** The current pricing page lists no free plan. Neither the docs index nor the full docs mention a 30% limit ([llms.txt](https://docs.musixmatch.com/llms.txt)). See Open questions.

**Lookup**

- **ISRC works directly.** `track.lyrics.get` takes `commontrack_id` or `track_isrc` ([track.lyrics.get](https://docs.musixmatch.com/api-reference/lyrics-catalog/track-lyrics-get)). `track.subtitle.get`, the time-synced lyrics, also takes `track_isrc` ([track.subtitle.get](https://docs.musixmatch.com/api-reference/lyrics-catalog/track-subtitle-get)). `matcher.lyrics.get` takes title and artist, or ISRC ([matcher.lyrics.get](https://docs.musixmatch.com/api-reference/lyrics-catalog/matcher-lyrics-get)).
- **Matching advice.** Musixmatch recommends the ISRC first, then title and artist. For synced lyrics, "choose the one that most closely matches your track's duration" ([Implementation guidelines](https://docs.musixmatch.com/implementation-guidelines)).
- **Fit with muse-man.** This matches the ISRC the app already gets from MusicKit.

**Display rules**

- **Tracking:** show `lyrics_copyright` whenever lyrics are shown, and load `pixel_tracking_url` or `script_tracking_url` on each view ([Lyrics views tracking](https://docs.musixmatch.com/lyrics-views-tracking)).
- **Badge:** add the "Lyrics powered by" image linked to `backlink_url` ([Implementation guidelines](https://docs.musixmatch.com/implementation-guidelines)).
- **Restrictions:** apply per-country restrictions. Restricted lyrics come back with an empty `lyrics_body` ([Content Restrictions](https://docs.musixmatch.com/content-restrictions)).
- **Japan:** disable copy and paste for traffic from Japan ([Checklist](https://docs.musixmatch.com/checklist)).

**API Terms of Service** ([about.musixmatch.com/apiterms](https://about.musixmatch.com/apiterms), last updated 24 June 2025)

- **Non-commercial by default (1.1, 2.2.1).** The licence is "solely … for non-commercial purposes" unless agreed in writing. No commercial use or monetising "without the express prior written approval".
- **Approval before going public (2.1.4).** "obtain the prior written approval of Musixmatch before making web pages which contain Musixmatch Data accessible to the public".
- **Credit and tracking (2.1.5, 2.1.11).** Credit Musixmatch with a "powered by Musixmatch" link, and let Musixmatch track access.
- **No sub-licensing (2.2.6).** Relevant to sharing lyrics with other Musicians in a Space.
- **No karaoke (2.2.13).** Musixmatch Data may not be used "in connection with any marketing, karaoke, video games". Whether a practice view that scrolls synced lyrics counts as karaoke would need asking.
- **Deletion on termination (7.2.1).** "you must delete all Musixmatch Data obtained from the API".

**What this means for muse-man**

- **Cost and secrets.** A key that must stay secret, a monthly cost, a badge and backlink, and view tracking all go against the preferences behind [ADR 0003](../adr/0003-song-lookup-via-musickit-and-reccobeats.md). That ADR rejected GetSongBPM for needing "an API key with a backlink".
- **No CloudKit storage.** Caching is Enterprise-only, so storing lyrics on a Song in CloudKit is not allowed on self-serve plans. Lyrics would have to be fetched each time they're shown.

## Genius

- **Auth:** an OAuth2 or client access token ([Genius API docs](https://docs.genius.com/), read through the [2026-10-30 Wayback snapshot](https://web.archive.org/web/20261030225208/https://docs.genius.com/) because the live page serves a bot check). A keyless `GET api.genius.com/search` returned 401, "This call requires an access_token" (2026-11-24).
- **No lyrics text documented.** The docs describe a song as "a document hosted on Genius. It's usually music lyrics." `GET /songs/:id` returns "details about the document itself and information about all the referents that are attached to it". No lyrics-body field or lyrics endpoint is documented, and the docs show no ISRC lookup.
- **Commercial use needs a licence.** "Commercial use of the Genius API is not allowed without a license. Please reach out to api-sales@genius.com" (same docs page).
- **Scraping is banned.** The Terms forbid "data mining, robots, scraping or similar data gathering or extraction methods". You may not "modify, copy, frame, scrape … distribute" Genius Content without written authorisation ([Genius Terms](https://genius.com/static/terms), read through the [2026-11-21 snapshot](https://web.archive.org/web/20261121234546/https://genius.com/static/terms)).
- **Not usable** for showing lyrics.

## lyrics.ovh

- **Endpoint:** `GET https://api.lyrics.ovh/v1/{artist}/{title}` returns `{ "lyrics": "..." }` or a 404. No key ([NTag/lyrics.ovh README](https://github.com/NTag/lyrics.ovh)).
- **Wonderwall test (2026-11-24):** returned 200 in about 1.1 s with plain lyrics. The line breaks differ from LRCLIB's.
- **Provenance: scraping.** The README says LRCLIB is "asked first". When LRCLIB has nothing, it queries NetEase, eLyrics.net, Genius, AZLyrics, Paroles.net, LyricsMania, Letras.mus.br and Lyrics.com in parallel. The live server runs with Genius, AZLyrics, LyricsMania, Letras and Lyrics.com turned off. Scraping Genius breaks Genius's Terms (above).
- **No terms, licence for the lyrics, rate limits or uptime promise.** The MIT licence covers only the code. Plain text only, with no ISRC and no sync.
- **Adds nothing over LRCLIB** except worse provenance.

## LyricFind

- **Licensed, business-to-business only.** LyricFind sells "Lyric Display" in three formats: static, line-by-line and word-by-word. The only way in is "Please fill in the form and we will be in touch!" ([LyricFind Lyric Display](https://www.lyricfind.com/products/lyric-display)).
- **No public docs or pricing.** Its documentation site is marked "Internal Use Only!" ([docs.lyricfind.com](https://docs.lyricfind.com/)). There is no self-serve sign-up, public API reference or public pricing.
- **Not realistic** for a small app without a sales contract.

## ISRC lookup

| Source | ISRC lookup? |
|---|---|
| Musixmatch | Yes: `track.lyrics.get`, `track.subtitle.get` and `matcher.lyrics.get` accept `track_isrc` |
| Apple | Gives the ISRC, but no lyrics |
| ShazamKit | Gives the ISRC, but no lyrics |
| LRCLIB | No. Matches on title, artist, album and duration; MusicKit already supplies all four |
| Genius | Not documented |
| lyrics.ovh | No |
| LyricFind | Not publicly documented |

## App Store guidelines that apply

From the [App Review Guidelines](https://developer.apple.com/app-store/review/guidelines/):

- **5.2.1:** "Don't use protected third-party material such as trademarks, copyrighted works, or patented ideas in your app without permission". Lyrics are copyrighted works owned by music publishers.
- **5.2.2:** "If your app uses, accesses, monetizes access to, or displays content from a third-party service, ensure that you are specifically permitted to do so under the service's terms of use. Authorization must be provided upon request." LRCLIB's registration offers an authorisation document for this. Musixmatch's Grow plan lists an "App Store certificate".
- **4.5.2(ii):** "Using the MusicKit APIs is not a replacement for securing the licenses you might need for a deeper or more complex music integration." Using MusicKit does not license lyrics.

## Open questions

- **Musixmatch free tier and 30% truncation.** Older third-party write-ups describe a free plan with 30% of lyrics. The current pricing page lists no free plan, the docs never mention truncation, and the developer portal's sign-up is disabled. I could not confirm whether a free or trial key still exists, or whether lower plans return full lyrics. Checking would need sign-up or asking sales@musixmatch.com.
- **Musixmatch App Store certificate.** What the Grow plan's "App Store certificate" says, and whether Grow includes the commercial-use approval the API Terms require (1.1, 2.2.1), is not stated publicly.
- **Musixmatch and karaoke.** Whether a practice view that scrolls synced lyrics counts as "karaoke" under API Terms 2.2.13 would need asking Musixmatch.
- **LRCLIB terms.** LRCLIB publishes no terms on commercial use, caching or attribution, and the maintainer has not answered issues #111 and #134. The contents of its "API authorization document" can only be seen after registering, which I did not do.
- **LRCLIB provenance.** Where the "background lyrics fetching service" gets lyrics from is not documented.
- **LRCLIB coverage.** Only Wonderwall was tested. Coverage for the Musician's actual repertoire, and how often MusicKit's duration falls outside the ±2 s match window, are untested.
- **Apple's direction.** I didn't watch the full WWDC26 MusicKit session, so I can't rule out lyrics news in it. Apple's documentation as of 2026-11-24 shows none.
- **App Review in practice.** I found no first-party statement of how App Review treats apps that show crowd-sourced lyrics. Only the guideline text above.
