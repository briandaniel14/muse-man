# Shared Spaces, with practice history kept private

CloudKit sharing has two limits that matter here. When an object is shared, every object related to it is shared too, and an object can belong to only one share. So we don't share individual Songs or Collections. Each Song and Collection lives in exactly one place, either the Musician's private Library or one Shared Space (one CloudKit share zone per Space), and sharing means moving it into a Space. Practice Sessions and Practice Entries never enter a Space. A Practice Entry refers to its Part and its Recording by identifier, not by a Core Data relationship, so that sharing a Part doesn't pull in the practice history.

## Consequences

- A Song needed in two Spaces exists as two separate Songs.
- Instruments also live in exactly one Library or Space, the same one as the Songs whose Parts use them; a Song moving into a Space matches its Parts' Instruments by name there, or creates them.
- When a Musician leaves or is removed from a Space, they get a private copy of the Songs that have their Parts, with their own Parts and Recordings.
- Code that goes from a Practice Entry to its Part or Recording has to look it up by its identifier, and must cope with it being missing, for example after it was deleted or left behind in a Space.
