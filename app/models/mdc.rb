#version;code;text_de;text_it;text_fr;prefix
class Mdc
  include Mongoid::Document

  field :code
  field :text, localize: true
  field :version
  field :prefix

  has_and_belongs_to_many :specialities

  index({ code: 1, version: 1 }, { unique: true })
end