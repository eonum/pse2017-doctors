class Speciality
  include Mongoid::Document
  include Mongoid::Elasticsearch

  has_and_belongs_to_many :keywords
  has_and_belongs_to_many :mdcs

  field :code, type: Integer
  field :name, localize: true
  field :fallbacks, type: Array, default: []
  field :compounds, type: Array, default: []

  elasticsearch!({ callbacks: false })

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

  def self.compounds_for(specialites)
    codes = specialites.map(&:code)
    Speciality.where(:compounds.ne => []).to_a.select { |fmh| (fmh.compounds - codes).empty? }
  end
end
