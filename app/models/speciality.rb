class Speciality
  include Mongoid::Document

  field :code, type: Integer
  field :name, localize: true
  field :fallbacks, type: Array, default: []
end
