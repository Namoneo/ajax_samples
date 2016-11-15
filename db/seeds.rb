Song.delete_all
Artist.delete_all

artist1 = Artist.create(name: "Charlie Puth")
artist2 = Artist.create(name: "Bruno Mars")
artist3 = Artist.create(name: "Michael Bublé")

Song.create(name: "One Call Away", artist: artist1)
Song.create(name: "We don't talk anymore", artist: artist1)

Song.create(name: "Grenade", artist: artist2)
Song.create(name: "Just the Way You Are", artist: artist2)

Song.create(name: "Everything", artist: artist3)
Song.create(name: "It's A Beautiful Day", artist: artist3)
