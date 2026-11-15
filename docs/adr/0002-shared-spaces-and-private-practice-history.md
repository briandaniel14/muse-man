# Shared Spaces, with practice history kept private

CloudKit sharing has two limits that matter here. When an object is shared, every object related to it is shared too, and an object can belong to only one share. So we don't share individual Songs or Collections. Each Song and Collection lives in exactly one place, either the Musician's private Library or one Shared Space (one CloudKit share zone per Space), and sharing means moving it into a Space. Practice Sessions and Practice Entries never enter a Space. A Practice Entry refers to its Part by identifier, not by a Core Data relationship, so that sharing a Part doesn't pull in the practice history.

## Consequences

- A Song needed in two Spaces exists as two separate Songs.
- When a Musician leaves or is removed from a Space, they get a private copy of the Songs that have their Parts, with their own Parts and Recordings.
- Code that goes from a Practice Entry to its Part has to look the Part up by its identifier, and must cope with the Part being missing, for example after it was deleted or left behind in a Space.
