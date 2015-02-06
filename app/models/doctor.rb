class Doctor
  include Mongoid::Document
  include Mongoid::Elasticsearch
  include Geocoder::Model::Mongoid

  has_and_belongs_to_many :specialities, inverse_of: nil

  field :doc_id, type: Integer
  field :name
  field :title
  field :address
  field :email
  field :phone1
  field :phone2
  field :canton
  field :docfields, type: Array, default: []
  field :location, type: Array, default: [8.5, 47]

  elasticsearch!({ callbacks: false })

  index({ name: 1, title: 1 }, { unique: true, drop_dups: true })
  index({ doc_id: 1 })

  geocoded_by :address, coordinates: :location
  reverse_geocoded_by :location

  scope :with_speciality, ->(field) { where(docfields: field) }
  scope :in_canton, ->(canton) { where(canton: canton) }

  def nametitle
    "#{title}-#{name}"
  end

  def to_param
    doc_id
  end

  def clean_address
    address.gsub(/\u00a0/, ' ')
  end
end
