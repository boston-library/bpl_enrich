module BplEnrich
  class LCSH

    #Take LCSH subjects and make them standard.
    def self.standardize(value)

      if value.blank?
        return ''
      end

      #Remove stuff that is quoted (quotation for first and last words)..
      value = value.gsub(/^['"]/, '').gsub(/['"]$/, '').strip

      #Remove ending periods ... except when an initial or etc.
      if value.last == '.' && value[-2].match(/[^A-Z]/) && !value[-4..-1].match('etc.')
        value = value.slice(0..-2)
      end

      #Fix when '- -' occurs
      value = value.gsub(/-\s-/,'--')

      #Fix for "em" dashes - two types?
      value = value.gsub('—','--')

      #Fix for "em" dashes - two types?
      value = value.gsub('–','--')

      #Fix for ' - ' combinations
      value = value.gsub(' - ','--')

      #Remove white space after and before  '--'
      value = value.gsub(/\s+--/,'--')
      value = value.gsub(/--\s+/,'--')

      #Ensure a value still exists after all the replacements
      return '' if value.blank?

      #Ensure first work is capitalized
      value[0] = value.first.capitalize[0]

      #Strip an white space
      value = BplEnrich.strip_value(value)

      return value
    end


  end
end
