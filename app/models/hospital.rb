class Hospital
  include Mongoid::Document
  include Geocoder::Model::Mongoid
  include Mongoid::Elasticsearch

  embeds_many :ratings

  field :doc_id, type: Integer
  field :name
  field :title
  field :address
  field :email
  field :phone1
  field :phone2
  field :canton
  field :location, type: Array, default: [7.43, 46.96] # Close to Berne

  elasticsearch!

  index({ doc_id: 1 }, { unique: true })

  geocoded_by :address, coordinates: :location
  reverse_geocoded_by :location

  scope :in_canton, ->(canton) { where(canton: canton) }

  def to_param
    doc_id
  end
end

class Rating
  include Mongoid::Document

  embedded_in :hospial

  field :code
  field :level, type: Integer
end
