module ReadyForI18N
  class HtmlTextExtractor
    SKIP_TAGS = [[/<script/i,/<\/script>/i],[/javascript_tag/i,/end %>/i],[/<%/,/%>/],[/<style/i,/\/style>/i]]
    SKIP_INLINE_TAG = [/<script>(.*?)<\/script>/i,/<%(.*?)%>/,/<(.*?)>/,/<(.*)$/,/^(.*)>/,/&nbsp;/]
    SEPERATOR = '_@@@_'

    include ReadyForI18N::ExtractorBase
    
    protected 
    def values_in_line(line)

      SKIP_INLINE_TAG.inject(line.clone){|memo,tag| memo.gsub(tag,SEPERATOR)}.strip.split SEPERATOR
    end

    def skip_line?(s)

      @stack ||= []
      return true if s.nil? || s.strip.size == 0
      jump_in_tag = SKIP_TAGS.find{ |start_tag,end_tag| s =~ start_tag}

      if s.include?("=\"<%") or s.include?("='<%")
        return true
      end

      @stack.push jump_in_tag[1] if jump_in_tag
      unless @stack.empty?
        end_tag_match = s.match(@stack.last) 
        if end_tag_match
          @stack.pop
          return skip_line?(end_tag_match.post_match)
        end
      end
      return !@stack.empty?
    end

    def to_value(s)
      s
    end

    def replace_line(line,e)
      repeat = line.scan(e).size
      replaced = t_method(e,true)
      return line if repeat == 0
      return line.sub!(e,replaced) if repeat == 1
      if repeat > 1
        line.gsub!(/>\s*#{e}\s*</,">#{replaced}<")
        line.gsub!(/>\s*#{e}/,">#{replaced}")
      end
    end
    def key_prefix
      'text'
    end
  end
end
