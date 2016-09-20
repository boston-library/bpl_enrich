module BplEnrich
  class Dates

    def self.is_numeric? (string)
      true if Float(string) rescue false
    end

    def self.convert_month_words(date_string)
      return_date_string = date_string.clone

      date_string = date_string.gsub(/[,\/\.]/, ' ').squeeze(' ') #switch periods, slashes, and commas that can seperate dates with spaces
      if date_string.split(' ').any? { |word| Date::MONTHNAMES.include?(word.humanize) || Date::ABBR_MONTHNAMES.include?(word.gsub('.', '').humanize) }
        return_date_string = ''
        was_numeric = false

        date_string.split(' ').each do |date_word|
          if Date::MONTHNAMES.include?(date_word.humanize)
              current_value = Date::MONTHNAMES.index(date_word).to_s.rjust(2, '0')
          elsif Date::ABBR_MONTHNAMES.include?(date_word.humanize)
            current_value = Date::ABBR_MONTHNAMES.index(date_word).to_s.rjust(2, '0')
          else
              current_value = date_word
          end
          if is_numeric?(current_value)
            if was_numeric
              return_date_string += "/#{current_value.to_s.rjust(2, '0')}"
            else
              was_numeric = true
              return_date_string += " #{current_value.to_s.rjust(2, '0')}"
            end
          else
            was_numeric = false
            return_date_string += " #{current_value}"
          end
        end
      end

      return return_date_string
    end

    # a function to convert date data from OAI feeds into MODS-usable date data
    # assumes date values containing ";" have already been split
    # returns hash with :single_date, :date_range, :date_qualifier, and/or :date_note values
    def self.standardize(value)

      date_data = {} # create the hash to hold all the data
      source_date_string = value.strip # variable to hold original value

      original_value = value
      value = convert_month_words(value) #Stuff like April 7, 1983

      # weed out obvious bad dates before processing
      if (value.match(/([Pp]re|[Pp]ost|[Bb]efore|[Aa]fter|[Uu]nknown|[Uu]ndated|n\.d\.)/)) ||
          (value.match(/\d\d\d\d-\z/)) || # 1975-
          (value.match(/\d\d-\d\d\/\d\d/)) || # 1975-09-09/10
          (value.match(/\d*\(\d*\)/)) ||  # 1975(1976)
          (value.scan(/\d\d\d\d/).length > 2) || # 1861/1869/1915
          (value.scan(/([Ee]arly|[Ll]ate|[Mm]id|[Ww]inter|[Ss]pring|[Ss]ummer|[Ff]all)/).length > 1) ||
          # or if data does not match any of these
          (!value.match(/(\d\dth [Cc]entury|\d\d\d-\?*|\d\d\d\?|\d\d\?\?|\d\d\d\d)/))
        date_data[:date_note] = source_date_string
      else
        # find date qualifier
        if value.include? '?'
          date_data[:date_qualifier] = 'questionable'
        elsif value.match(/\A[Cc]/)
          date_data[:date_qualifier] = 'approximate'
        elsif (value.match(/[\[\]]+/)) || (value.match(/[(][A-Za-z, \d]*[\d]+[A-Za-z, \d]*[)]+/)) # if [] or ()
          date_data[:date_qualifier] = 'inferred'
        end

        # remove unnecessary chars and words
        value = value.gsub(/[\[\]\(\)\.,']/,'')
        value = value.gsub(/(\b[Bb]etween\b|\bcirca\b|\bca\b|\Aca|\Ac)/,'').strip

        # differentiate between ranges and single dates
        if (value.scan(/\d\d\d\d/).length == 2) ||
            (value.include? '0s') ||          # 1970s
            (value.include? 'entury') ||      # 20th century
            (value.match(/(\A\d\d\d\?|\A\d\d\?\?|\A\d\d\d-\?*|\d\d\d\d-\d\z|\d\d\d\d\/[\d]{1,2}\z)/)) ||
            (value.match(/([Ee]arly|[Ll]ate|[Mm]id|[Ww]inter|[Ss]pring|[Ss]ummer|[Ff]all)/)) ||
            ((value.match(/\d\d\d\d-\d\d\z/)) && (value[-2..-1].to_i > 12)) # 1975-76 but NOT 1910-11

          # RANGES
          date_data[:date_range] = {}

          # deal with date strings with 2 4-digit year values separately
          if value.scan(/\d\d\d\d/).length == 2

            # convert weird span indicators ('or','and','||'), remove extraneous text
            value = value.gsub(/(or|and|\|\|)/,'-').gsub(/[A-Za-z\?\s]/,'')

            if value.match(/\A[12][\d]{3}-[01][\d]-[12][\d]{3}-[01][\d]\z/) # 1895-05-1898-01
              date_data_range_start = value[0..6]
              date_data_range_end = value[-7..-1]
            elsif value.match(/\A[12][\d]{3}\/[12][\d]{3}\z/) # 1987/1988
              date_data_range_start = value[0..3]
              date_data_range_end = value[-4..-1]
            else
              range_dates = value.split('-') # split the dates into an array
              range_dates.each_with_index do |range_date,index|
                # format the data properly
                if range_date.include? '/' # 11/05/1965
                  range_date_pieces = range_date.split('/')
                  # 11/05/1965 case
                  if range_date_pieces.last.length == 4
                    range_date_piece_year = range_date_pieces.last
                    range_date_piece_month = range_date_pieces.first.length == 2 ? range_date_pieces.first : '0' + range_date_pieces.first
                    if range_date_pieces.length == 3
                      range_date_piece_day = range_date_pieces[1].length == 2 ? range_date_pieces[1] : '0' + range_date_pieces[1]
                    end
                    value_to_insert = range_date_piece_year + '-' + range_date_piece_month
                    value_to_insert << '-' + range_date_piece_day if range_date_piece_day
                  #1860/10 case
                  elsif range_date_pieces.first.length == 4
                    range_date_piece_year = range_date_pieces.first
                    range_date_piece_month = range_date_pieces[1].length == 2 ? range_date_pieces[1] : '0' + range_date_pieces[1]
                    if range_date_pieces.length == 3
                      range_date_piece_day = range_date_pieces[2].length == 2 ? range_date_pieces[2] : '0' + range_date_pieces[2]
                    end
                    value_to_insert = range_date_piece_year + '-' + range_date_piece_month
                    value_to_insert << '-' + range_date_piece_day if range_date_piece_day
                  end

                elsif range_date.match(/\A[12][\d]{3}\z/)
                  value_to_insert = range_date
                end
                # add the data to the proper variable
                if value_to_insert
                  if index == 0
                    date_data_range_start = value_to_insert
                  else
                    date_data_range_end = value_to_insert
                  end
                end
              end
            end
          else
            # if there are 'natural language' range values, find, assign to var, then remove
            text_range = value.match(/([Ee]arly|[Ll]ate|[Mm]id|[Ww]inter|[Ss]pring|[Ss]ummer|[Ff]all)/).to_s
            if text_range.length > 0
              date_data[:date_qualifier] ||= 'approximate' # TODO - remove this??
              value = value.gsub(/#{text_range}/,'').strip
            end

            # deal with ranges for which 'natural language' range values are ignored
            if value.match(/\A1\d\?\?\z/) # 19??
              date_data_range_start = value[0..1] + '00'
              date_data_range_end = value[0..1] + '99'
            elsif value.match(/\A[12]\d\d-*\?*\z/) # 195? || 195-? || 195-
              date_data_range_start = value[0..2] + '0'
              date_data_range_end = value[0..2] + '9'
            elsif value.match(/\A[12]\d\d\d[-\/][\d]{1,2}\z/) # 1956-57 || 1956/57 || 1956-7
              if value.length == 7 && (value[5..6].to_i > value[2..3].to_i)
                date_data_range_start = value[0..3]
                date_data_range_end = value[0..1] + value[5..6]
              elsif value.length == 6 && (value[5].to_i > value[3].to_i)
                date_data_range_start = value[0..3]
                date_data_range_end = value[0..2] + value[5]
              end
              date_data[:date_note] = source_date_string if text_range.length > 0
            end
            # deal with ranges where text range values are evaluated
            value = value.gsub(/\?/,'').strip # remove question marks

            # centuries
            if value.match(/([12][\d]{1}th [Cc]entury|[12][\d]{1}00s)/) # 19th century || 1800s
              if value.match(/[12][\d]{1}00s/)
                century_prefix_date = value.match(/[12][\d]{1}/).to_s
              else
                century_prefix_date = (value.match(/[12][\d]{1}/).to_s.to_i-1).to_s
              end
              if text_range.match(/([Ee]arly|[Ll]ate|[Mm]id)/)
                if text_range.match(/[Ee]arly/)
                  century_suffix_dates = %w[00 39]
                elsif text_range.match(/[Mm]id/)
                  century_suffix_dates = %w[30 69]
                else
                  century_suffix_dates = %w[60 99]
                end
              end
              date_data_range_start = century_suffix_dates ? century_prefix_date + century_suffix_dates[0] : century_prefix_date + '00'
              date_data_range_end = century_suffix_dates ? century_prefix_date + century_suffix_dates[1] : century_prefix_date + '99'
            else
              # remove any remaining non-date text
              value.match(/[12][1-9][1-9]0s/) ? is_decade = true : is_decade = false # but preserve decade-ness
              remaining_text = value.match(/\D+/).to_s
              value = value.gsub(/#{remaining_text}/,'').strip if remaining_text.length > 0

              # decades
              if is_decade
                decade_prefix_date = value.match(/\A[12][1-9][1-9]/).to_s
                if text_range.match(/([Ee]arly|[Ll]ate|[Mm]id)/)
                  if text_range.match(/[Ee]arly/)
                    decade_suffix_dates = %w[0 3]
                  elsif text_range.match(/[Mm]id/)
                    decade_suffix_dates = %w[4 6]
                  else
                    decade_suffix_dates = %w[7 9]
                  end
                end
                date_data_range_start = decade_suffix_dates ? decade_prefix_date + decade_suffix_dates[0] : decade_prefix_date + '0'
                date_data_range_end = decade_suffix_dates ? decade_prefix_date + decade_suffix_dates[1] : decade_prefix_date + '9'
              else
                # single year ranges
                single_year_prefix = value.match(/[12][0-9]{3}/).to_s
                if text_range.length > 0
                  if text_range.match(/[Ee]arly/)
                    single_year_suffixes = %w[01 04]
                  elsif text_range.match(/[Mm]id/)
                    single_year_suffixes = %w[05 08]
                  elsif text_range.match(/[Ll]ate/)
                    single_year_suffixes = %w[09 12]
                  elsif text_range.match(/[Ww]inter/)
                    single_year_suffixes = %w[01 03]
                  elsif text_range.match(/[Ss]pring/)
                    single_year_suffixes = %w[03 05]
                  elsif text_range.match(/[Ss]ummer/)
                    single_year_suffixes = %w[06 08]
                  else text_range.match(/[F]all/)
                  single_year_suffixes = %w[09 11]
                  end
                  date_data_range_start = single_year_prefix + '-' + single_year_suffixes[0]
                  date_data_range_end = single_year_prefix + '-' + single_year_suffixes[1]
                end
              end
              # if possibly significant info removed, include as note
              date_data[:date_note] = source_date_string if remaining_text.length > 1
            end
          end

          # insert the values into the date_data hash
          if date_data_range_start && date_data_range_end
            date_data[:date_range][:start] = date_data_range_start
            date_data[:date_range][:end] = date_data_range_end
          else
            date_data[:date_note] ||= source_date_string
            date_data.delete :date_range
          end

        else
          # SINGLE DATES
          value = value.gsub(/\?/,'') # remove question marks
          # fix bad spacing (e.g. December 13,1985 || December 3,1985)
          value = value.insert(-5, ' ') if value.match(/[A-Za-z]* \d{6}/) || value.match(/[A-Za-z]* \d{5}/)

          # try to automatically parse single dates with YYYY && MM && DD values
          if Timeliness.parse(original_value).nil?
            # start further processing
            value.split(' ').each do |split_value|
              if split_value.match(/\A[12]\d\d\d[-\/\.][01][0-9]\z/) # yyyy-mm || yyyy/mm || yyyy.mm
                split_value = split_value.gsub(/[,\/\.]/, '-').squeeze('-')
                date_data[:single_date] = split_value
              elsif split_value.match(/\A[12]\d\d\d[-\/\.][01][0-9][-\/\.][01][0-9]\z/) # yyyy-mm-dd || yyyy/mm/dd || yyyy.mm.dd
                split_value = split_value.gsub(/[,\/\.]/, '-').squeeze('-')
                date_data[:single_date] = split_value
              elsif split_value.match(/\A[01]?[1-9][-\/][12]\d\d\d\z/) # mm-yyyy || m-yyyy || mm/yyyy
                split_value = '0' + split_value if split_value.match(/\A[1-9][-\/\.][12]\d\d\d\z/) # m-yyyy || m/yyyy
                date_data[:single_date] = split_value[3..6] + '-' + split_value[0..1]
              elsif split_value.match(/\A[12]\d\d\d\z/) # 1999
                date_data[:single_date] = split_value
              elsif split_value.match(/\A[01]?[1-9][-\/\.][01]?[1-9][-\/\.][12]\d\d\d\z/) # mm-dd-yyyy || m-dd-yyyy || mm/dd/yyyy
                split_value = split_value.gsub(/[,\/\.]/, '/').squeeze('-')
                date_data[:single_date] = "#{split_value.split('/')[2]}-#{split_value.split('/')[0]}-#{split_value.split('/')[1]}" if split_value.include?('/')
                date_data[:single_date] = "#{split_value.split('-')[2]}-#{split_value.split('-')[0]}-#{split_value.split('-')[1]}" if split_value.include?('-')
                date_data[:single_date] = "#{split_value.split('.')[2]}-#{split_value.split('.')[0]}-#{split_value.split('.')[1]}" if split_value.include?('.')
              end

            end

            if value.split(' ').length > 1 || date_data[:single_date].blank?
              date_data[:date_note] = source_date_string
            end
          else
            date_data[:single_date] = Timeliness.parse(original_value).strftime("%Y-%m-%d")
          end

        end

      end

      # some final validation, just in case
      date_validation_array = []
      date_validation_array << date_data[:single_date] if date_data[:single_date]
      date_validation_array << date_data[:date_range][:start] if date_data[:date_range]
      date_validation_array << date_data[:date_range][:end] if date_data[:date_range]
      date_validation_array.each do |date_to_val|
        if date_to_val.length == '7'
          bad_date = true unless date_to_val[-2..-1].to_i.between?(1,12) && !date_to_val.nil?
        elsif
        date_to_val.length == '10'
          bad_date = true unless Timeliness.parse(original_value) && !date_to_val.nil?
        end
        if bad_date
          date_data[:date_note] ||= source_date_string
          date_data.delete :single_date if date_data[:single_date]
          date_data.delete :date_range if date_data[:date_range]
        end
      end

      # if the date slipped by all the processing somehow!
      if date_data[:single_date].nil? && date_data[:date_range].nil? && date_data[:date_note].nil?
        date_data[:date_note] = source_date_string
      end

      date_data

    end
  end
end