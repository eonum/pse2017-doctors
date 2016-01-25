class Doctor
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  field :name
  field :title
  field :address
  field :email
  field :phone1
  field :phone2
  field :canton
  field :docfields, type: Array, default: []
  field :location, type: Array, default: [7.43, 46.96]

  geocoded_by :address, coordinates: :location
  reverse_geocoded_by :location

  index({ location: '2d'}, { min: -200, max: 200 })

  scope :with_speciality, ->(field) { where(docfields: field) }
  scope :in_canton, ->(canton) { where(canton: canton) }

  def nametitle
    "#{title}-#{name}"
  end

  def clean_address
    address.gsub(/\u00a0/, ' ')
  end
end