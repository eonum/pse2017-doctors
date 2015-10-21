class Speciality
  include Mongoid::Document
  include MultiLanguageText
  has_many :variables

  field :name, localize: true

  field :name_de, :type => String, :default => 'Name Deutsch'
  field :name_fr, :type => String, :default => 'Nom français'
  field :name_it, :type => String, :default => 'Nome italiano'
  field :description_de, :type => String, :default => ''
  field :description_fr, :type => String, :default => ''
  field :description_it, :type => String, :default => ''
end
