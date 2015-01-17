class SpecialityFinder
  def find(code)
    code_type code
  end

  private

    def code_type(code)
      case code
        when icd_regex
          :icd
        when chop_regex
          :chop
        else
          :none
      end
    end

    def icd_regex
      /^[A-TV-Z][0-9][A-Z0-9](\.[A-Z0-9]{1,4})?$/
    end

    def chop_regex
      /(^[A-Z]?(\d{2}(\.\w{2})?(\.\w{1,2})?)$)/
    end
end