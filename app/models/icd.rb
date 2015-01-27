class Icd
  include Mongoid::Document
  include Mongoid::Elasticsearch

  field :code
  field :text, localize: true
  field :version
  field :inclusiva, type: Array, localize: true
  field :exclusiva, type: Array, localize: true
  field :synonyms, type: Array, localize: true
  field :subclasses, type: Array
  field :drgs, type: Array

  index({ code: 1, version: 1 }, { unique: true })

  elasticsearch!

  def to_param
    code
  end

  def superclass
    nil if code.length == 3

    offset = code[-2] == '.' ? -3 : -2
    Icd.where(code: code[0..offset]).exists? ? code[0..offset] : nil
  end

  def subclass_objects
    subclasses.map{ |sc| Icd.find_by(code: sc) }
  end

  def clean_text
    related_regex = /\s*\{(.*?)\}\s*/
    t = text.gsub(related_regex, '')
    r = text.match related_regex

    return t, r
  end

end
