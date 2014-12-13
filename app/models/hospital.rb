class Hospital
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  field :doc_id, type: Integer
  field :name
  field :title
  field :address
  field :email
  field :phone1
  field :phone2
  field :canton
  field :location, type: Array, default: [7.43, 46.96] # Close to Berne

  geocoded_by :address, coordinates: :location
  reverse_geocoded_by :location
  scope :in_canton, ->(canton) { where(canton: canton) }
end
