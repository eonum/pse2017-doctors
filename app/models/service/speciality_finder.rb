class SpecialityFinder

  def find(code)
    case code_type code
      when :icd then find_for_icd code
      when :chop then find_for_chop code
      else []
    end
  end

  private

    def find_for_icd(code)

      return [] unless Icd.where(code: code).exists?

      # Search thesaurs
      thesaur = Thesaur.where(codes: code).first
      from_thesaur = thesaur ? thesaur.specialities : []

      # Search keywords
      text  = Icd.find_by(code: code).text_translations[:de].downcase
      matched_keywords = []
      Keyword.icd.each do |k|
        matched_keywords << k if text.include? k.keyword
      end

      from_keymatch = matched_keywords.map(&:specialities)

      from_thesaur | from_keymatch
    end

    def find_for_chop(code)
      []
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
end