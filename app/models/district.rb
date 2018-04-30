class District < ApplicationRecord
  validates_presence_of :number, :geometry
  validates_uniqueness_of :number
end
