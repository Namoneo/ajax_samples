class Song < ApplicationRecord
  belongs_to :artist
  validates_presence_of :name
end
