# Codaisseurify

This project is part of the homework during the Intermediate Bootcamp.

# Part 1 / Models & Seeds

In this part of the assignment, you'll create a Rails app to manage a collection of Songs and their associated Artists. We'll only create the models for now. We'll be adding controllers and views later.

## Create the Application

### ✎ Exercises

* Create a new Rails app.
* Make sure to use Postgres for your database.
* Make sure that no test suite is installed with it.

### ➜ Solution

```bash
# create the app
$ rails new codaisseurify -d postgresql -T

# change directories
$ cd codaisseurify/

# create the database
$ rails db:create
```

## Generate the Models

### ✎ Exercises

* Set up two models `Song` and `Artist`. Define the relationship between them: any artist can have multiple songs.

### ➜ Solution

```bash
# create Artist model
$ rails g model Artist name:string

# create Song model (already with the association)
$ rails g model Song name:string artist:references

# run the migrations
$ rails db:migrate
```

And update the `app/models/artist.rb` to declare the association:

```ruby
# app/models/artist.rb

class Artist < ApplicationRecord
  has_many :songs
end
```

And add some validation into the `Song` model:

```ruby
# app/models/song.rb

class Song < ApplicationRecord
  belongs_to :artist

  validates_presence_of :name
end
```

## Add some Seeds

### ✎ Exercises

* Seed the database with some initial songs and artists.

### ➜ Solution

```ruby
# db/seeds.rb

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
```

And seed the database:

```bash
$ rails db:seed
```

## Inspect Data in Rails Console

### ✎ Exercises

* Use the Rails console to check that the database contains the data after seeding.

### ➜ Solution

```bash
# log into the rails console
$ rails console

# check all the artists
>> Artist.all

# check all the songs
>> Song.all

# check the songs that belongs to the first artist
>> Artist.first.songs

# check the artist of the first song
>> Song.first.artist
```





# Part 2 / Artists Overview Page

## Overview

### ✎ Exercises

* In this page visitors can see a list of all the artists in the database.

### ➜ Solution

```bash
# create the artists controller
$ rails g controller Artists
```

With the following content:

```ruby
# app/controllers/artists_controller.rb

class ArtistsController < ApplicationController
  def index
    @artists = Artist.all
  end
end
```

```bash
# create the index view
$ touch app/views/artists/index.html.erb
```

With the following content:

```html
<!-- app/views/artists/index.html.erb -->

<h1>Artists Overview</h1>

<ul>
  <% @artists.each do |artist| %>
    <li><%= link_to artist.name, "#" %></li>
  <% end %>
</ul>
```

And update the routes:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root "artists#index"
end
```

Visit the page in the browser:

```bash
$ rails server
```

## Filters

### ✎ Exercises

* Visitors should be able to order artists by `name` or `created_at` date.

### ➜ Solution

> TODO

## Cloudinary

### ✎ Exercises

* Artists should have a picture, properly hosted in Cloudinary ;-)

### ➜ Solution

> TODO

## Testing

* Add unit tests for the `Song` and `Artist` models, testing the association between the two.

### ➜ Solution

> TODO






# Part 3 / Artist Show Page

## Overview

### ✎ Exercises

* When clicking on an artist, visitors are redirected to their show page.
* In this page visitors can see a list of the songs of the artist.

### ➜ Solution

Generate a controller for the songs:

```bash
$ rails g controller Songs
```

With the following content:

```ruby
# app/controllers/songs_controller.rb

class SongsController < ApplicationController
  def index
    @artist = Artist.find(params[:artist_id])
    @songs = @artist.songs
  end
end
```

Update the routes:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root "artists#index"

  resources :artists, only: [:index] do
    resources :songs, only: [:index]
  end
end
```

Update the link in the artists overview page to link to the artist page:

```html
<li><%= link_to artist.name, artist_songs_path(artist) %></li>
```

Create a new file `app/views/songs/index.html.erb`:

```bash
$ touch app/views/songs/index.html.erb
```

With the following content:

```html
<h1><%= @artist.name %></h1>

<ul id="songs">
  <% @songs.each do |song| %>
    <li><%= song.name %></li>
  <% end %>
</ul>
```






# Part 4 / AJAX

## Add Song

### ✎ Exercises

* Users can add songs via AJAX.

### ➜ Solution 1 / Without AJAX

Let's first have a look at how to make it work without AJAX.

Update the `SongsController`:

```ruby
# app/controllers/songs_controller.rb

class SongsController < ApplicationController
  before_action :set_artist

  def index
    @song = Song.new
    @songs = @artist.songs
  end

  def create
    @song = @artist.songs.build(song_params)

    if @song.save
      redirect_to artist_songs_path(@artist), notice: 'Song was successfully created.'
    else
      redirect_to artist_songs_path(@artist), alert: 'Song could not be created.'
    end
  end

  private

  def set_artist
    @artist = Artist.find(params[:artist_id])
  end

  def song_params
    params.require(:song).permit(:name)
  end
end
```

Update the routes:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root "artists#index"

  resources :artists, only: [:index] do
    resources :songs, only: [:index, :create]
  end
end
```

Create a new partial `app/views/songs/_form.html` with the following content:

```html
<%= form_for [artist, song] do |f| %>
  <%= f.text_field :name, placeholder: "Song name", id: "song-name" %>
<% end %>
```

And render it at the end of the `app/views/songs/index.html.erb`:

```html
<%= render "form", artist: @artist, song: @song %>
```

### ➜ Solution 2 / With jQuery

Update the `create` action in the `SongsController`:

```ruby
def create
  song = @artist.songs.build(song_params)

  if song.save
    render status: 200, json: {
      message: "Song successfully created",
      song: song
    }.to_json
  else
    render status: 422, json: {
      error: song.errors.full_messages
    }.to_json
  end
end
```

Update the partial `app/views/songs/_form.html` with the following content to include the `artist_id`:

```html
<%= form_for [artist, song] do |f| %>
  <%= f.text_field :name, placeholder: "Song name", id: "song-name", data: { artist_id: artist.id } %>
  <ul id="errors"></ul>
<% end %>
```

Rename the file `app/assets/javascripts/songs.coffee` into `app/assets/javascripts/songs.js` and add the following content:

```javascript
function createSong(name, artistId) {
  $.ajax({
    type: "POST",
    url: "/artists/" + artistId + "/songs.json",
    data: JSON.stringify({
      song: { name: name }
    }),

    contentType: "application/json",
    dataType: "json"})

    .success(function(data) {
      var listItem = $('<li></li>').html(data.song.name);
      $("#songs").append( listItem );
      $("#song-name").val(null);
      $("#notice").html(data.message);
    })

    .fail(function(error) {
      errors = JSON.parse(error.responseText).error

      $.each(errors, function(index, value) {
        var listItem = $('<li></li>').html(value);
        $("#errors").append(listItem);
      });
    });
}

function submitSong(event) {
  event.preventDefault();

  var name = $("#song-name").val();
  var artistId = $("#song-name").data("artist-id");

  createSong(name, artistId);
}

$(document).ready(function() {
  $("form").bind('submit', submitSong);
});
```

### ➜ Solution 3 / AJAX the Rails Way

Create a new partial `app/views/songs/_song.html.erb` with the following content:

```html
<li><%= song.name %></li>
```

And update the `index` view to render the content in the previous file:

```html
<h1><%= @artist.name %></h1>

<ul id="songs">
  <%= render @songs %>
</ul>

<%= render "form", artist: @artist, song: @song %>
```

Update the form:

```html
<%= form_for [artist, artist.songs.new], remote: true do |f| %>
  <%= f.text_field :name, placeholder: "Song name", id: "song-name" %>
<% end %>
```

Update the `create` action in the `SongsController`:

```ruby
def create
  @song = @artist.songs.build(song_params)
  @song.save!

  respond_to do |format|
    format.html { redirect_to artist_songs_path(@artist) }
    format.js # render songs/create.js.erb
  end
end
```

Create a new file `app/views/songs/create.js.erb` with the following content:

```javascript
$("#songs").append("<%= j render @song, artist: @artist %>");
$("#song-name").val(null);
```


## Remove Song

### ✎ Exercises

* Users can remove songs via AJAX.

### ➜ Solution 1 / Without AJAX

> TODO

### ➜ Solution 2 / With jQuery

> TODO

### ➜ Solution 3 / AJAX the Rails Way

Update the routes to include the `destroy` action:

```ruby
# config/routes.rb

Rails.application.routes.draw do
  root "artists#index"

  resources :artists, only: [:index] do
    resources :songs, only: [:index, :create, :destroy]
  end
end
```

Update the partial `app/views/songs/_song.html.erb`:

```html
<li id="song-<%= song.id %>">
  <%= song.name %>
  <%= link_to "Delete", artist_song_path(artist, song), method: :delete, remote: true %>
</li>
```

Add a new `destroy` action in the `SongsController` with the following content:

```ruby
# app/controllers/songs_controller.rb

def destroy
  @song = Song.find(params[:id])
  @song.destroy!

  @songs = @artist.songs

  respond_to do |format|
    format.html { redirect_to artist_songs_path(@artist) }
    format.js # render songs/create.js.erb
  end
end
```

Add a new file `app/views/songs/destroy.js.erb` with the following content:

```javascript
$("#songs").html("<%= j render @songs, artist: @artist %>");
```






## Remove All Songs

### ✎ Exercises

* Users can clean up all songs for that artist in one click, which also happens via AJAX.

### ➜ Solution 1 / Without AJAX

> TODO

### ➜ Solution 2 / With jQuery

> TODO

### ➜ Solution 3 / AJAX the Rails Way

Update the routes:

```ruby
Rails.application.routes.draw do
  root "artists#index"

  resources :artists, only: [:index] do
    resources :songs, only: [:index, :create, :destroy]
    delete "/destroy_all", to: "songs#destroy_all", as: :songs_destroy_all
  end
end
```

Add a new `destroy_all` action in the `SongsController`:

```ruby
def destroy_all
  @artist.songs.destroy_all

  respond_to do |format|
    format.html { redirect_to artist_songs_path(@artist) }
    format.js # render songs/destroy_all.js.erb
  end
end
```

Add a link in the `app/views/songs/index.html.erb`:

```html
<%= link_to "Delete All", artist_songs_destroy_all_path(artist), method: :delete, remote: true %>
```

Create a new file `app/views/songs/destroy_all.js.erb` with the following content:

```javascript
$("#songs").empty();
```





## Testing

### ✎ Exercises

* Add integration tests for the artist show page, related to the add songs, remove songs and clean up all songs functionalities.

### ➜ Solution

> TODO
