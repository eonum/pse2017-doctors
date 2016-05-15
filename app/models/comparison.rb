class Comparison
  include Mongoid::Document
  include MultiLanguageText

  has_and_belongs_to_many :variables

  field :name, localize: true

  field :name_de, type: String, default: 'Name Deutsch'
  field :name_fr, type: String, default: 'Nom français'
  field :name_it, type: String, default: 'Nome italiano'
  field :description_de, type: String, default: ''
  field :description_fr, type: String, default: ''
  field :description_it, type: String, default: ''
  field :image_link, type: String, default:''
  field :raw_html_icon, type: String, default:''

  field :base_year, type: String, default: '2013'
  field :is_draft, type: Boolean, default: false

  # only hospitals that meet the following limitations are considered for this comparison

  # field name of the limit field
  field :limit_field, type: String, default: nil
  # limit operator, one of '>', '<', 'exists', '='
  field :limit_operator, type: String, default: '>'
  # limit value if '>', '<' or '='
  field :limit_value, type: String, default: ''

  # sort comparisons according rank
  field :rank, type: Integer

  # The types of doctors relevant to this comparison
  field :doctor_fields, type: Array, default: []

  # get all hostpials that meet the limitiations.
  def hospitals
    var = Variable.where(field_name: limit_field).first
    return Hospital.all if var.nil?
    value = limit_value
    value = value.to_f if var.variable_type == :number || var.variable_type == :percentage
    field = limit_field
    field = "#{field}.#{base_year}" if var.is_time_series

    return Hospital.where(field => mongo_operator(limit_operator, value))
  end

  def includes hospital
    var = Variable.where(:field_name => limit_field).first
    return true if var.nil?
    value = limit_value
    value = value.to_f if var.variable_type == :number || var.variable_type == :percentage
    field = limit_field
    h_value = hospital[field]
    return false if h_value.nil?
    h_value  =  h_value[base_year] if var.is_time_series
    return h_value > value if limit_operator == '>'
    return h_value < value if limit_operator == '<'
    return !h_value.nil? && h_value != value if limit_operator == '<>'
    return h_value == value if limit_operator == '=' || limit_operator == nil
  end

  def mongo_operator op, value
    ops = {'$gt' => value} if op == '>'
    ops = {'$lt' => value} if op == '<'
    ops = {'$exists' => true, '$ne' => value} if op == '<>'
    ops = {'$exists' => true} if op == 'exists'
    ops = value if op == '=' || op == nil
    return ops
  end

  def variables
    # Unfortunately this is necessary because mongoid won't return
    # has_many relations in the order stored in the database. Maybe
    # someone has a better solution for this problem?
    variables = []
    self.variable_ids.each {|id| variables << Variable.find(id)}
    variables
  end
end
