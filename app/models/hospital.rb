class Hospital
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  has_many :hospital_locations

  field :name
  field :address1
  field :address2
  field :bfs_typo
  field :canton

  field :location, type: Array, default: [7.43, 46.96] # Close to Berne

  geocoded_by :address2, coordinates: :location
  reverse_geocoded_by :location

  index({ name: 1 }, { unique: true })
end
