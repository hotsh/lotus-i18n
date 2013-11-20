# The main module for all Lotus related functionality.
module Lotus
  # The internationalization and localization module.
  module I18n
    require 'i18n'

    # Translate the given token to the locale's translation.
    def self.translate(*args)
      ::I18n.t(*args)
    end

    # Translates the given verb for the current locale.
    def self.verb(*args)
      token = args.shift
      self.translate("verb.#{token}", *args)
    end

    # Translates the given object as a singular for the current locale.
    def self.single_object(*args)
      token = args.shift
      options = args.last if args.last.is_a? Hash
      self.translate("object.singular_#{token}", *args)
    end

    # Translates the given object as a plural for the current locale.
    def self.plural_object(*args)
      token = args.shift
      options = args.last if args.last.is_a? Hash
      self.translate("object.plural_#{token}", *args)
    end

    # Translates the given object for the current locale.
    def self.object(*args)
      token = args.shift
      self.translate("object.#{token}", *args)
    end

    # Translates the given pronoun for the current locale.
    def self.pronoun(*args)
      token = args.shift
      self.translate("pronoun.#{token}", *args)
    end

    # Translates the given possessive pronoun for the current locale.
    def self.possessive_pronoun(*args)
      token = args.shift
      self.translate("possessive_pronoun.#{token}", *args)
    end

    # Translates the given action for the current locale.
    def self.action(*args)
      token = args.shift
      self.translate("action.#{token}", *args)
    end

    # Translates the given category for the current locale.
    def self.category(*args)
      token = args.shift
      self.translate("category.#{token}", *args)
    end

    # Translates the given field for the current locale.
    def self.field(*args)
      token = args.shift
      self.translate("field.#{token}", *args)
    end

    # Localize the given object for the current locale.
    def self.localize(*args)
      ::I18n.l(*args)
    end

    # Produces a sentence describing the given Lotus::Activity.
    def self.sentence(options = {})
      options ||= {}

      locale = options[:locale].to_s || ::I18n.locale.to_s
      default = ::I18n.default_locale.to_s

      # Use the system default locale and then English as fallback
      filename = File.join(File.dirname(__FILE__), 'locales', locale, 'grammar.yml')
      unless File.exist? filename
        locale = default
        filename = File.join(File.dirname(__FILE__), 'locales', locale, 'grammar.yml')
        unless File.exist? filename
          locale = "en"
        end
      end

      filename = File.join(File.dirname(__FILE__), 'locales', locale, 'grammar.yml')
      grammar = YAML.load_file(filename)

      result = ""

      grammar[locale].each do |hash|
        if hash["for"].select{|e| !components.keys.include?(e.intern)}.empty?
          if hash["match"] && hash["match"].count > 0
            matches = hash["match"]

            unless hash["match"][0].is_a? Array
              matches = [hash["match"]]
            end

            violations = matches.select do |rule|
              !components[rule[0].intern].match(Regexp.new(rule[1]))
            end

            next unless violations.empty?
          end

          result = hash["do"]
          components.each do |component, value|
            if value.is_a? Symbol
              result = result.gsub /\S*%#{Regexp.escape(component.to_s)}%\S*/ do |match|
                self.translate(match.gsub("%#{component.to_s}%", value.to_s).strip)
              end
            else
              result = result.gsub("%#{component.to_s}%", value.to_s)
            end
          end
          break
        end
      end

      result
    end
  end
end
