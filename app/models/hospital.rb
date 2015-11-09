class Hospital
  include Mongoid::Document

  has_many :hospital_locations

  field :name
  field :title
  field :address1
  field :address2
  field :bfs_typo
  field :legal_status
  field :num_locations
  field :cantons, :Type => Array

  index({ name: 1 }, { unique: true })
end
