module BplEnrich
  class Authorities

    def self.parse_language(language_value)
      return_hash = {}
      authority_check = Qa::Authorities::Loc.new
      authority_result = authority_check.search(URI.escape(language_value), 'iso639-2')

      if authority_result.present?
        authority_result = authority_result.select{|hash| hash['label'].downcase == language_value.downcase || hash['id'].split('/').last.downcase == language_value.downcase }
        if  authority_result.present?
          return_hash[:uri] = authority_result.first["id"].gsub('info:lc', 'http://id.loc.gov')
          return_hash[:label] = authority_result.first["label"]
        end
      end

      return return_hash
    end

    #TODO: Research why authority_result = authority_check.search(URI.escape('ctb'), 'relators') doesn't work.
    def self.parse_role(role_value)
      return_hash = {}
      authority_check = Qa::Authorities::Loc.new
      authority_result = authority_check.search(URI.escape(role_value), 'relators')
      if authority_result.present?
        authority_result = authority_result.select{|hash| hash['label'].downcase == role_value.downcase }
        if  authority_result.present?
          return_hash[:uri] = authority_result.first["id"].gsub('info:lc', 'http://id.loc.gov')
          return_hash[:label] = authority_result.first["label"]
        end
      end

      return return_hash
    end

    def self.parse_name_for_role(name)
      return_hash = {:name=>name}

      #Make sure we have at least three distinct parts of 2-letter+ words. Avoid something like: Steven C. Painter or Painter, Steven C.
      #Possible Issue: Full name of Steven Carlos Painter ?
      potential_role_check = name.to_ascii.match(/[\(\"\',]*\w\w+[\),\"\']* [\w\.,\d\-\"]*[\w\d][\w\d][\w\.,\d\-\"]* [\(\"\',]*\w\w+[\),\"\']*$/) || name.split(/[ ]+/).length >= 4

      if potential_role_check.present?
        authority_check = Qa::Authorities::Loc.new

        #Check the last value of the name string...
        role_value = name.to_ascii.match(/(?<=[\(\"\', ])\w+(?=[\),\"\']*$)/).to_s
        authority_result = authority_check.search(URI.escape(role_value), 'relators')
        if authority_result.present?

          authority_result = authority_result.select{|hash| hash['label'].downcase == role_value.downcase}
          if  authority_result.present?
            #Remove the word and any other characters around it. $ means the end of the line.
            #
            return_hash[:name] = name.sub(/[\(\"\', ]*\w+[\),\"\']*$/, '').gsub(/^[ ]*:/, '').strip
            return_hash[:uri] = authority_result.first["id"].gsub('info:lc', 'http://id.loc.gov')
            return_hash[:label] = authority_result.first["label"]
          end
        end

        #Check the last value of the name string...
        role_value = name.to_ascii.match(/\w+(?=[\),\"\']*)/).to_s
        authority_result = authority_check.search(URI.escape(role_value), 'relators')
        if authority_result.present? && return_hash.blank?

          authority_result = authority_result.select{|hash| hash['label'].downcase == role_value.downcase}
          if  authority_result.present?
            #Remove the word and any other characters around it. $ means the end of the line.
            return_hash[:name] = name.sub(/[\(\"\', ]*\w+[ \),\"\']*/, '').gsub(/^[ ]*:/, '').strip
            return_hash[:uri] = authority_result.first["id"].gsub('info:lc', 'http://id.loc.gov')
            return_hash[:label] = authority_result.first["label"]
          end
        end
      end

      return return_hash
    end
  end
end