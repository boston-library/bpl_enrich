module Qa::Authorities
  module Loc
    module GenericAuthorityExtensions
      def build_query_url(q)
         escaped_query = CGI.escape(q)
         authority_fragment = Loc.get_url_for_authority(subauthority) + CGI.escape(subauthority)
         "http://id.loc.gov/search/?q=#{escaped_query}&q=#{authority_fragment}&format=json"
      end
    end
    class GenericAuthority < Base
      prepend GenericAuthorityExtensions
    end
  end
end
