#code;code_short;text_de;text_fr;text_it;version;inclusions_de;inclusions_fr;inclusions_it;exclusions_de;exclusions_fr;exclusions_it;descriptions_de;descriptions_fr;descriptions_it
class Chop
  include Mongoid::Document

  field :code
  field :code_short
  field :text, localize: true
  field :description, localize: true
  field :version
  field :synonyms, localize: true, type: Array
  field :exclusiva, localize: true, type: Array
  field :inclusiva, localize: true, type: Array
  field :drgs, type: Array

  index({ code: 1, version: 1 }, { unique: true })
  index({ code_short: 1, version: 1 }, { unique: true })

end
