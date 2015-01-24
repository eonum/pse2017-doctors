class Thesaur
  include Mongoid::Document

  has_and_belongs_to_many :specialities, inverse_of: nil

  field :name
  field :codes, type: Array, default: []
end