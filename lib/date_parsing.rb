# encoding: utf-8
if RUBY_VERSION.to_f >= 1.9

  # Port from home_run library Ruby 1.9 format fixes.
  class Date
    module Format
      # Holds some constants used by the pure ruby parsing code.
      #
      # The STYLE constant (a hash) allows the user to modify the parsing
      # of DD/DD/DD and DD.DD.DD dates.  For DD/DD/DD dates, you
      # can set the :slash entry to :mdy (month/day/year,
      # :dmy (day/month/year), or :ymd (year/month/day).  The same
      # can be done for DD.DD.DD dates using the :dot entry.  Example:
      #
      #   Date::Format::STYLE[:slash] = :mdy
      #   Date::Format::STYLE[:dot] = :dmy
      if RUBY_VERSION < '1.8.7'
        # On Ruby 1.8.6 and earlier, DD/DD/DD and DD.DD.DD dates
        # are interpreted by default as month, day, year.
        STYLE = {:dot=>:mdy, :slash=>:mdy}
      elsif RUBY_VERSION >= '1.9.0'
        # On Ruby 1.9.0 and later , DD/DD/DD and DD.DD.DD dates
        # are interpreted by default as year, month, and day.
        STYLE = {:dot=>:ymd, :slash=>:ymd}
      else
        # On Ruby 1.8.7, DD/DD/DD is interpreted by default as
        # month, day, year, and DD.DD.DD is interpreted
        # by default as year, month, day.
        STYLE = {:dot=>:ymd, :slash=>:mdy}
      end
    end

    # Parse a slash separated date. Examples of formats handled:
    #
    #   1/2/2009
    #   12/3/07
    def self._parse_sla(str, e) # :nodoc:
      if str.sub!(%r|('?-?\d+)/\s*('?\d+)(?:\D\s*('?-?\d+))?|, ' ') # '
        case Format::STYLE[:slash]
        when :mdy
          s3e(e, $3, $1, $2)
        when :dmy
          s3e(e, $3, $2, $1)
        else
          s3e(e, $1, $2, $3)
        end
        true
      end
    end

    # Parse a period separated date. Examples of formats handled:
    #
    #   1.2.2009
    #   12.3.07
    def self._parse_dot(str, e) # :nodoc:
      if str.sub!(%r|('?-?\d+)\.\s*('?\d+)\.\s*('?-?\d+)|, ' ') # '
        case Format::STYLE[:dot]
        when :mdy
          s3e(e, $3, $1, $2)
        when :dmy
          s3e(e, $3, $2, $1)
        else
          s3e(e, $1, $2, $3)
        end
        true
      end
    end
  end

  Date::Format::STYLE[:slash] = :mdy
  Date::Format::STYLE[:dot] = :mdy

end

Date::DATE_FORMATS[:default] = lambda { |date| I18n.l(date) }
