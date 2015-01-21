class Speciality
  include Mongoid::Document

  has_and_belongs_to_many :doctors

  field :code, type: Integer
  field :name, localize: true
  field :fallbacks, type: Array, default: []

  index({ code: 1 }, { unique: true })

  def to_param
    code
  end
end
