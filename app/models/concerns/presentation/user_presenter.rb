module Presentation
  module UserPresenter
    extend ActiveSupport::Concern

    # in plain english returns 'true' or 'false' if the user is active or not
    #
    # @param [none]
    # @return [ String ]
    def display_active
      active?.to_s
    end

    # gives the user's first and last name if available, otherwise returns the users email
    #
    # @param [none]
    # @return [ String ]
    def name
      (first_name? && last_name?) ? [first_name.capitalize, last_name.capitalize ].join(" ") : email
    end

    # name and email string for the user
    # ex. '"John Wayne" "jwayne@badboy.com"'
    #
    # @param  [ none ]
    # @return [ String ]
    def email_address_with_name
      "\"#{name}\" <#{email}>"
    end
  end
end
