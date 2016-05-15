class Doctor
  include Mongoid::Document
  include Geocoder::Model::Mongoid

  has_and_belongs_to_many :hospitals

  field :name
  field :title
  field :address
  field :email
  field :website
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
  def hospitals
    # Unfortunately this is necessary because mongoid won't return
    # has_many relations in the order stored in the database. Maybe
    # someone has a better solution for this problem?
    hospitals = []
    self.hospital_ids.each {|id| hospitals << Hospital.find(id)}
    hospitals
  end
end