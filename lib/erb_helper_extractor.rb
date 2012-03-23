module ReadyForI18N
  class ErbHelperExtractor
    LABEL_IN_HELPER_PATTERN =  %w{label_tag link_to field_set_tag submit_tag button_to}.map{|h| /#{h}[\s\w_]*('|")([\w ]*)(\1)/ }

    include ReadyForI18N::ExtractorBase
    
    protected 
    def values_in_line(line)
      LABEL_IN_HELPER_PATTERN.map{|h| line.match(h).captures.join if line =~ h}.compact
    end
    def skip_line?(s)
      false
    end
    def to_value(s)
      s[1..-2]
    end
    def replace_line(line,e)
       line.gsub!(e,t_method(e[1..-2]))
    end

    def key_prefix
      'label'
    end
  end
end