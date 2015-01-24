class Speciality
  include Mongoid::Document

  has_and_belongs_to_many :doctors
  embeds_many :chop_keywords, class_name: 'Keyword', inverse_of: :chop_speciality
  embeds_many :icd_keywords, class_name: 'Keyword', inverse_of: :icd_speciality

  field :code, type: Integer
  field :name, localize: true
  field :fallbacks, type: Array, default: []
  field :compounds, type: Array, default: []

  scope :chop_keyword, ->(keyword) { where('chop_keywords.keyword' => keyword) }
  scope :icd_keyword, ->(keyword) { where('icd_keywords.keyword' => keyword) }
  scope :keyword, ->(keyword) { any_of({ 'chop_keywords.keyword' => keyword },{ 'icd_keywords.keyword' => keyword }) }

  index({ code: 1 }, { unique: true })

  def to_param
    code
  end

  def self.generate_compounds_for(specialites)
    codes = specialites.map(&:code)

    fmhs = Speciality.where(:compounds.ne => []).to_a

    fmhs.select { |fmh| (fmh.compounds - codes).empty? }
  end
end

class Keyword
  include Mongoid::Document

  field :keyword
  field :exclusiva, type: Array, default: []

  embedded_in :chop_speciality, class_name: 'Speciality', inverse_of: :chop_keywords
  embedded_in :icd_speciality, class_name: 'Speciality', inverse_of: :icd_keywords
end
