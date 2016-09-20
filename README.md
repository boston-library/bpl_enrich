# BplEnrich

This gem is used to standardize and enhance metadata.

For this initial release, only the date parsing and lcsh subject standardizing code has been moved into this gem.
More will be coming soon.

## Installation

Add this line to your application's Gemfile:

    gem 'bpl_enrich'

## Usage

### Dates

To standardize a date. use the following:

    BplEnrich::Dates.standardize('<date_string>')

This will return a hash that can contain the following possible keys:

    :date_note - if unable to convert or extra nonconverted data was in the string, this will be populated.
    :single_date - value if only a single date.
    :date_range - values of a date range. Has keys :start and :end contained within.

### LCSH

A LCSH library to standardize LCSH heading based on DPLA's guidelines exists. For example, it will remove
special character double dashes, extra spaces, exta periods, etc. To use this, do the following

    BplEnrich::LCSH.standardize('<lcsh-like_string>')

The return value is just the standardized string.

### Authority Querying

These are helper functions that wrap around functionality from the following gem:

    https://github.com/projecthydra-labs/questioning_authority

#### Parse a Possible Language Role Value

If you have a value like "English" or "eng", you can get the LOC information via:

    BplEnrich::Authorities.parse_language('<language_string>')

    #Will return {} if no match and {:label=>"label value", :uri=>"uri value"} if match.

#### Parse a Possible Role Value

If you have a value like "Contributor", you can get the LOC identifier via:

    BplEnrich::Authorities.parse_role('<role_string>')

    #Will return {} if no match and {:label=>"label value", :uri=>"uri value"} if match.

#### Parse a Name for a Possible Role Portion

If you have a value like "Steven Anderson (Contributor)", you can get the LOC identifier via:

    BplEnrich::Authorities.parse_role('<name_string>')

    #Will return {:name=><name_string>} if no match.
    #Will return {:label=>"label value", :uri=>"uri value", :name=>"non-role-part} if match.

## Contributing

1. As this is geared for our use case, let me know about your interest in this gem and how you would like it to function.
2. Fork it
3. Create your feature branch (`git checkout -b my-new-feature`)
4. Commit your changes (`git commit -am 'Added some feature'`)
5. Push to the branch (`git push origin my-new-feature`)
6. Create new Pull Request