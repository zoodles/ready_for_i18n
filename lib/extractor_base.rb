require 'stringio'

module ReadyForI18N
  module ExtractorBase
    
    def self.use_dot(on_off)
      @use_dot = on_off
    end
    def self.use_dot?
      @use_dot
    end
    def self.key_mapper=(mapper)
      @key_mapper = mapper
    end
    def self.key_mapper
      @key_mapper
    end

    def self.i18n_namespace=(namespace)
      @i18n_namespace = namespace
    end

    def self.i18n_namespace
      @i18n_namespace
    end

    def extract(input)
      buffer = StringIO.new
      input.each_line do |line|
        unless skip_line?(line)
          values_in_line(line).each do |e|
            if can_replace?(e)
              yield(to_key(e),to_value(e)) if block_given?
              replace_line(line,e)
            end
          end
        end
        buffer << line
      end
      buffer.string
    end
    def to_key(s)
      val = to_value(s)
      result = (ExtractorBase.key_mapper) ? ExtractorBase.key_mapper.key_for(val) : val.scan(/\w+/).join('_').downcase

      key_prefix ? "#{key_prefix}_#{result}" : result
    end
    def can_replace?(e)
      e.strip.size > 1
    end
    def t_method(val,wrap=false)
      result =  ReadyForI18N::I18nGenerator.dict.get_key(val,ReadyForI18N::I18nGenerator.path)
      m = ExtractorBase.use_dot? ? "t('#{ReadyForI18N::ExtractorBase.i18n_namespace}.#{result}')" : "t(#{ReadyForI18N::ExtractorBase.i18n_namespace}.#{result})"
      wrap ? "<%=#{m}%>" : m
    end
  end
end