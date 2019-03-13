module BplEnrich
  class Authorities

    # return the full URI for a given authority (LCSH, NAF, etc)
    def self.authority_uri(auth)
      case auth
        when 'lctgm'
          'http://id.loc.gov/vocabulary/graphicMaterials'
        when 'gmgpc'
          'http://id.loc.gov/vocabulary/graphicMaterials'
        when 'lcsh'
          'http://id.loc.gov/authorities/subjects'
        when 'aat'
          'http://vocab.getty.edu/aat'
        when 'naf'
          'http://id.loc.gov/authorities/names'
        when 'marcgt'
          'http://id.loc.gov/vocabulary/genreFormSchemes/marcgt'
        when 'homosaurus'
          'http://homosaurus.org/terms'
        when 'marcorg'
          'http://id.loc.gov/vocabulary/organizations'
        else
          ''
      end
    end

    # although we use iso639-2 as our lang authority, we need to search using
    # MARC Languages vocab, because id.loc.gov no longer provides labels for
    # iso639-2. In most cases, 3-letter lang code is same in both vocabs,
    # so we can live with this.
    def self.parse_language(language_value)
      return_hash = {}
      authority_check = Qa::Authorities::Loc.subauthority_for('languages')
      authority_result = authority_check.search(CGI.escape(language_value))

      if authority_result.present?
        authority_result = authority_result.select { |hash| hash['label'].downcase == language_value.downcase || hash['id'].split('/').last.downcase == language_value.downcase }
        if authority_result.present?
          return_hash[:uri] = authority_result.first["id"].gsub(/info:lc/, 'http://id.loc.gov').gsub(/languages/, 'iso639-2')
          return_hash[:label] = authority_result.first["label"]
        end
      end

      return return_hash
    end

    #TODO: Research why authority_result = authority_check.search(URI.escape('ctb'), 'relators') doesn't work.
    def self.parse_role(role_value)
      return_hash = {}
      authority_check = Qa::Authorities::Loc.subauthority_for('relators')
      authority_result = authority_check.search(CGI.escape(role_value))
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
      return_hash = {name: name}

      #Make sure we have at least three distinct parts of 2-letter+ words. Avoid something like: Steven C. Painter or Painter, Steven C.
      #Possible Issue: Full name of Steven Carlos Painter ?
      potential_role_check = name.to_ascii.match(/[\(\"\',]*\w\w+[\),\"\'\:]* [\w\.,\d\-\"]*[\w\d][\w\d][\w\.,\d\-\"]* [\(\"\',]*\w\w+[\),\"\']*$/) || name.split(/[ ]+/).length >= 4

      if potential_role_check.present?
        authority_check = Qa::Authorities::Loc.subauthority_for('relators')

        #Check the last value of the name string...
        role_value = name.to_ascii.match(/(?<=[\(\"\', ])\w+(?=[\),\"\']*$)/).to_s
        authority_result = authority_check.search(CGI.escape(role_value))
        if authority_result.present?

          authority_result = authority_result.select{|hash| hash['label'].downcase == role_value.singularize.downcase}
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
        authority_result = authority_check.search(CGI.escape(role_value))
        if authority_result.present? && return_hash[:uri].blank?

          authority_result = authority_result.select{|hash| hash['label'].downcase == role_value.singularize.downcase}
          if  authority_result.present?
            #Remove the word and any other characters around it. $ means the end of the line.
            return_hash[:name] = name.sub(/[\(\"\', ]*\w+[ \),\"\']*/, '').gsub(/^[ ]*\:/, '').strip
            return_hash[:uri] = authority_result.first["id"].gsub('info:lc', 'http://id.loc.gov')
            return_hash[:label] = authority_result.first["label"]
          end
        end
      end

      return return_hash
    end
  end
end
