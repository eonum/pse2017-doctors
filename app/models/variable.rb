# encoding: UTF-8
require 'date'

class Variable
  include Mongoid::Document
  include MultiLanguageText

  has_and_belongs_to_many :specialities

  # Corresponds to the field name
  field :field_name
  # rank is used to order variables
  field :rank, :type => Integer, :default => 0
  #  import_rank is used as a column identifier in imports. 1 is the first column
  field :import_rank, :type => Integer, :default => 0
  # all variable sets by name containing this variable
  field :variable_sets, :type => Array, :default => []

  field :name_de, :type => String, :default => 'Name Deutsch'
  field :name_fr, :type => String, :default => 'Nom français'
  field :name_it, :type => String, :default => 'Nome italiano'
  field :description_de, :type => String, :default => ''
  field :description_fr, :type => String, :default => ''
  field :description_it, :type => String, :default => ''

  field :variable_type, :type => Symbol, :default => :string # can be one of :percentage, :string, :boolean, :number,

  # possible values if enum string, null, empty => free text or numeric
  field :values, :type => Array, :default => []
  field :values_de, :type => Array, :default => []
  field :values_fr, :type => Array, :default => []
  field :values_it, :type => Array, :default => []

  def is_enum
    return values != nil && !values.empty?
  end

  def values_option_list(locale)
    options = []
    descriptions = self.localized_field('values', locale)
    (0..values.length-1).each do |i|
      options << [descriptions.length > i ? descriptions[i] : values[i], values[i]]
    end
    options
  end

  def value_by_key(key, locale)
    descriptions = self.localized_field('values', locale)
    (0..values.length-1).each do |i|
      return descriptions[i] if values[i] == key
    end
    return 'unknown'
  end

end
