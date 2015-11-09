class Hospital
  include Mongoid::Document

  has_many :hospital_locations

  field :name
  field :address1
  field :address2
  field :bfs_typo
  field :canton

  index({ name: 1 }, { unique: true })
end
