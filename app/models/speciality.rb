class Speciality
  include Mongoid::Document

  has_and_belongs_to_many :doctors

  field :code, type: Integer
  field :name, localize: true
  field :fallbacks, type: Array, default: []
end
