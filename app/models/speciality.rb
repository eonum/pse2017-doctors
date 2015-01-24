class Speciality
  include Mongoid::Document

  has_and_belongs_to_many :doctors
  has_and_belongs_to_many :keywords

  field :code, type: Integer
  field :name, localize: true
  field :fallbacks, type: Array, default: []
  field :compounds, type: Array, default: []

  index({ code: 1 }, { unique: true })

  def to_param
    code
  end

  def self.keyword(keyword, type = :either)
    keywords = if type == :either
                Keyword.where(keyword: keyword)
              else
                Keyword.where(type: type, keyword: keyword)
              end
    keywords.map(&:specialities)
  end

  def self.generate_compounds_for(specialites)
    codes = specialites.map(&:code)

    fmhs = Speciality.where(:compounds.ne => []).to_a

    fmhs.select { |fmh| (fmh.compounds - codes).empty? }
  end
end
