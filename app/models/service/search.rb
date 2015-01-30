class Search

  def self.search(query)
    models = [Icd, Chop, Speciality, Doctor, Hospital]

    results = []
    models.each do |model|
      search = model.es.search(query)
      results.concat search.results
    end

    results.sort_by(&:_score).reverse
  end

end