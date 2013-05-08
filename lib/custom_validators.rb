module CustomValidators

  class Emails
    # please refer to : http://stackoverflow.com/questions/703060/valid-email-address-regular-expression
    def self.email_validator
      /\A(|(([A-Za-z0-9]+_+)|([A-Za-z0-9]+\-+)|([A-Za-z0-9]+\.+)|([A-Za-z0-9]+\++))*[A-Za-z0-9]+@((\w+\-+)|(\w+\.))*\w{1,63}\.[a-zA-Z]{2,6})\z/i
    end
  end

  class Numbers
    def self.phone_number_validator
      #/\A\d?(?:(?:[\+]?(?:[\d]{1,3}(?:[ ]+|[\-.])))?[(]?(?:[\d]{3})[\-)]?(?:[ ]+)?)?(?:[a-zA-Z2-9][a-zA-Z0-9 \-.]{6,})(?:(?:[ ]+|[xX]|(i:ext[\.]?)){1,2}(?:[\d]{1,5}))?\z/
      /(?:\+?|\b)[0-9]{10}\b/
    end
    def self.us_and_canda_zipcode_validator
      /(\A\d{5}(-\d{4})?\z)|(\A[ABCEGHJKLMNPRSTVXYabceghjklmnprstvxy]{1}\d{1}[A-Za-z]{1} *\d{1}[A-Za-z]{1}\d{1}\z)/
    end

    def self.usps_tracking_number_validator
      /\b(91\d\d ?\d\d\d\d ?\d\d\d\d ?\d\d\d\d ?\d\d\d\d ?\d\d|91\d\d ?\d\d\d\d ?\d\d\d\d ?\d\d\d\d ?\d\d\d\d)\b/i
    end

    def self.fedex_tracking_number_validator
      /\A([0-9]{15}|4[0-9]{11})\z/
    end

    def self.ups_tracking_number_validator
      #/\b(1Z ?[0-9A-Z]{3} ?[0-9A-Z]{3} ?[0-9A-Z]{2} ?[0-9A-Z]{4} ?[0-9A-Z]{3} ?[0-9A-Z]|[\dT]\d\d\d ?\d\d\d\d ?\d\d\d)\b/i
      /\A(1Z\s*\d{3}\s*\d{3}\s*\d{2}\s*\d{4}\s*\d{3}\s*\d|[0-35-9]\d{3}\s*\d{4}\s*\d{4}|T\d{3}\s*\d{4}\s*\d{3})\z/
    end
  end

  class Names
    def self.name_validator
      #/([a-zA-Z-’'` ].+)/ \A and \z
      #/^([a-z])+([\\']|[']|[\.]|[\s]|[-]|)+([a-z]|[\.])+$/i
      #/^([a-z]|[\\']|[']|[\.]|[\s]|[-]|)+([a-z]|[\.])+$/i
      /\A([[:alpha:]]|[\\']|[']|[\.]|[\s]|[-]|)+([[:alpha:]]|[\.])+\z/i
    end
  end

  def validates_ssn(*attr_names)
    attr_names.each do |attr_name|
      validates_format_of attr_name,
        :with => /\A[\d]{3}-[\d]{2}-[\d]{4}\z/,
        :message => "must be of format ###-##-####"
    end
  end

=begin
  # CREDIT CARDS
  # * Visa: ^4[0-9]{12}(?:[0-9]{3})?$ All Visa card numbers start with a 4. New cards have 16 digits. Old cards have 13.
  # * MasterCard: ^5[1-5][0-9]{14}$ All MasterCard numbers start with the numbers 51 through 55. All have 16 digits.
  # * American Express: ^3[47][0-9]{13}$ American Express card numbers start with 34 or 37 and have 15 digits.
  # * Diners Club: ^3(?:0[0-5]|[68][0-9])[0-9]{11}$ Diners Club card numbers begin with 300 through 305, 36 or 38. All have 14 digits. There are Diners Club cards that begin with 5 and have 16 digits. These are a joint venture between Diners Club and MasterCard, and should be processed like a MasterCard.
  # * Discover: ^6(?:011|5[0-9]{2})[0-9]{12}$ Discover card numbers begin with 6011 or 65. All have 16 digits.
  # * JCB: ^(?:2131|1800|35\d{3})\d{11}$ JCB cards beginning with 2131 or 1800 have 15 digits. JCB cards beginning with 35 have 16 digits.
=end

  class CreditCards
    def self.validate_card(type)
      case type
      when 'VISA'     || 'visa'
        self.visa_validator
      when 'MC'       || 'MasterCard'
        self.mastercard_validator
      when 'AMEX'     || 'AmericanExpress'
        self.american_express_validator
      when 'Diners'   || 'DinersClub'
        self.diners_club_validator
      when 'Discover' || 'DiscoverCard'
        self.discover_validator
      when 'JCB'
        self.jcb_validator
      end
    end
    def self.visa_validator
      /^4[0-9]{12}(?:[0-9]{3})?$/
    end
    def self.mastercard_validator
      /^5[1-5][0-9]{14}$/
    end
    def self.american_express_validator
      /^3[47][0-9]{13}$/
    end
    def self.diners_club_validator
      /^3(?:0[0-5]|[68][0-9])[0-9]{11}$/
    end
    def self.discover_validator
      /^6(?:011|5[0-9]{2})[0-9]{12}$/
    end
    def self.jcb_validator
      /^(?:2131|1800|35\d{3})\d{11}$/
    end
  end
end
