class FieldRange
  include Mongoid::Document

  has_and_belongs_to_many :specialities, inverse_of: nil

  field :name
  field :beginning
  field :ending
  field :level, type: Integer
  field :type

  scope :icd, ->{ where(type: 'icd') }
  scope :chop, ->{ where(type: 'chop') }

  def self.specialities_for_code(code, type)

    code = case type
             when :icd then code[0..1]
             when :chop then code[0..2]
             else code
           end

    specialities = []
    FieldRange.where(type: type.to_s).each do |r|
      specialities.concat r.specialities.to_a if (code >= r.beginning and code <= r.ending)
    end

    specialities
  end
end