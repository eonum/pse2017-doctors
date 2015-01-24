class Keyword
  include Mongoid::Document

  field :keyword
  field :type
  field :exclusiva, type: Array, default: []

  has_and_belongs_to_many :specialities
end