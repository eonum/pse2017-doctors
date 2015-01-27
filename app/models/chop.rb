class Chop
  include Mongoid::Document
  include Mongoid::Elasticsearch

  field :code
  field :code_short
  field :text, localize: true
  field :description, localize: true
  field :version
  field :exclusiva, localize: true, type: Array
  field :inclusiva, localize: true, type: Array
  field :drgs, type: Array

  elasticsearch!

  index({ code: 1, version: 1 }, { unique: true })
  index({ code_short: 1, version: 1 }, { unique: true })

  def to_param
    code
  end

  def superclass
    nil if code.length == 2

    offset = code[-2] == '.' ? -3 : -2
    Chop.where(code: code[0..offset]).exists? ? code[0..offset] : nil
  end

  def subclasses
    Chop.where(code_short: /\A#{code_short}\w{1}\z/).map(&:code)
  end

end
