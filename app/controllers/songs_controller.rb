class SongsController < ApplicationController
  before_action :set_artist

  def index
    @songs = @artist.songs
  end

  def create
    @song = @artist.songs.build(song_params)
    @song.save!

    respond_to do |format|
      format.html { redirect_to artist_songs_path(@artist) }
      format.js # render songs/create.js.erb
    end
  end

  def destroy
    @song = Song.find(params[:id])
    @song.destroy!

    @songs = @artist.songs

    respond_to do |format|
      format.html { redirect_to artist_songs_path(@artist) }
      format.js # render songs/create.js.erb
    end
  end

  def destroy_all
    @artist.songs.destroy_all

    respond_to do |format|
      format.html { redirect_to artist_songs_path(@artist) }
      format.js # render songs/destroy_all.js.erb
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
