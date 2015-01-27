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
    code_short
  end

end
