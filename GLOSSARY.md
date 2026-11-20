# muse-man

A practice journal and song library for a musician who plays several instruments: what they've learned, how they're progressing, and what to practise next.

## Language

### Library

**Song**:
A piece of music, identified by title and artist, independent of any instrument.
_Avoid_: Track, tune, piece

**Part**:
A Song as played on one Instrument by one Musician, optionally labelled (such as "Lead" or "Drop D"); the unit whose learning progress is tracked.
_Avoid_: Arrangement, version, entry

**Part Note**:
A single standing note on a Part, such as chord shapes or reminders, edited over time rather than dated.
_Avoid_: Notes, description

**Musician**:
A person who owns Parts and practises them; each person using the app is one Musician.
_Avoid_: User, player, member

**Instrument**:
An instrument the Musician plays, such as guitar, piano or bass; it lives in one Library or Shared Space, the same one as the Songs whose Parts use it.

**Collection**:
A named, ordered list of Songs, such as a gig setlist or a repertoire; a Song can be in many Collections within the same Library or Shared Space.
_Avoid_: Setlist, playlist, folder

**Resource**:
A link to external learning material for a Song, such as a tab or a tutorial video.
_Avoid_: Reference, attachment

### Sharing

**Library**:
A Musician's private set of Songs and Collections.
_Avoid_: Catalogue, repertoire

**Shared Space**:
A named group of Musicians, such as a band or a teacher and student, whose Songs and Collections they all see; each Song and Collection lives in exactly one Library or Shared Space.
_Avoid_: Group, team, share

### Progress

**Status**:
How far along the musician is with a Part: Want to learn, Learning or Learned.
_Avoid_: Stage, level

**Due**:
A Learning or Learned Part whose next scheduled practice date has arrived, as set by spaced repetition.
_Avoid_: Rusty, overdue, stale

**Practice Next**:
The Musician's Due Parts, most overdue first.
_Avoid_: Queue, today, to-do

**Practice Session**:
One sitting of practice, either timed live or logged afterwards with its duration; several can happen in a day.
_Avoid_: Workout, sitting

**Practice Entry**:
A private record of practising one Part within a Practice Session, with a Rating and optionally a written note and a Recording; never visible in a Shared Space.
_Avoid_: Log, note

**Rating**:
How a Practice Entry went, one of Again, Hard, Good or Easy; it drives when the Part is next Due.
_Avoid_: Score, grade

**Recording**:
A dated audio capture of a Musician playing a Part, belonging to that Part; it may have been made during a Practice Entry.
_Avoid_: Take, clip
