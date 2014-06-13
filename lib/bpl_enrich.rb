module BplEnrich
  require "bpl_enrich/lcsh"
  require "bpl_enrich/dates"
  require "bpl_enrich/constants"
  require "bpl_enrich/authorities"
  require "timeliness"
  require "unidecoder"
  require "htmlentities"
  require "qa"

  # add some formats to Timeliness gem for better parsing
  Timeliness.add_formats(:date, 'm-d-yy', :before => 'd-m-yy')
  Timeliness.add_formats(:date, 'mmm[\.]? d[a-z]?[a-z]?[,]? yyyy')
  Timeliness.add_formats(:date, 'yyyy mmm d')

  def self.strip_value(value)
    if(value.blank?)
      return nil
    else
      if value.class == Float || value.class == Fixnum
        value = value.to_i.to_s
      end

      # Make sure it is all UTF-8 and not character encodings or HTML tags and remove any cariage returns
      return utf8Encode(value)
    end
  end

  #TODO: Better name for this. Should be part of an overall helped gem.
  def self.utf8Encode(value)
    return ::HTMLEntities.new.decode(ActionView::Base.full_sanitizer.sanitize(value.to_s.gsub(/\r?\n?\t/, ' ').gsub(/\r?\n/, ' ').gsub(/<br[\s]*\/>/,' '))).strip
  end

end
