class SpecialityFinder

  def find(code)
    specs = case code_type code
              when :icd then find_for_icd code
              when :chop then find_for_chop code
              else []
            end
    specs | Speciality.compounds_for(specs)
  end

  private

    def find_for_icd(code)
      return [] unless Icd.where(code: code).exists?

      # Search thesaurs
      thesaur = Thesaur.where(codes: code).first
      from_thesaur = thesaur ? thesaur.specialities : []

      # Search range
      from_range = FieldRange.specialities_for_code(code, :icd)

      # Search keywords
      text  = Icd.find_by(code: code).text_translations[:de].downcase
      from_keymatch = []
      Keyword.icd.each do |k|
        from_keymatch.concat k.specialities.to_a if text.include? k.keyword
      end

      from_thesaur | from_range | from_keymatch | default_specialities
    end

    def find_for_chop(code)
      return [] unless Chop.where(code: code).exists?

      # Search range
      from_range = FieldRange.specialities_for_code(code, :chop)

      # Search keywords
      text  = Chop.find_by(code: code).text_translations[:de].downcase
      from_keymatch = []
      Keyword.chop.each do |k|
        from_keymatch.concat k.specialities.to_a if text.include? k.keyword
      end

      from_range | from_keymatch | default_specialities
    end

    def code_type(code)
      case code
        when icd_regex then :icd
        when chop_regex then :chop
        else :none
      end
    end

    def icd_regex
      /^[A-TV-Z][0-9][A-Z0-9](\.[A-Z0-9]{1,4})?$/
    end

    def chop_regex
      /(^[A-Z]?(\d{2}(\.\w{2})?(\.\w{1,2})?)$)/
    end

    def default_specialities
      [Speciality.find_by(code: 5)]
    end
end