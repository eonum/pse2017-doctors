#code;text_de;text_fr;text_it;text_en;version;inclusions_de;inclusions_fr;inclusions_it;exclusions_de;exclusions_fr;exclusions_it;synonyms_de;synonyms_fr;synonyms_it;subclasses;most_relevant_drgs
class Icd
  include Mongoid::Document

  field :code
  field :text, localize: true
  field :version
  field :inclusiva, type: Array, localize: true
  field :exclusiva, type: Array, localize: true
  field :synonyms, type: Array, localize: true
  field :subclasses, type: Array
  field :drgs, type: Array

  index({ code: 1, version: 1 }, { unique: true })

  def to_param
    code
  end

end
