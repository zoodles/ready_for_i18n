module ReadyForI18N
  class LocaleDictionary
    def initialize(locale = nil)
      @locale = locale || 'en'
      @hash = {}
    end
    def push(key,value,path = nil)
      h = @hash
      path.each{|p| h[p] ||= {}; h = h[p] } if path
      if h[key] and h[key] != value
        key = "#{key}_#{value.size}"
        h[key] = value
      else
        h[key] = value
      end
    end
    def write_to(out)
      # out.puts "#{@locale}:"
      $KCODE = 'UTF8'
      out.puts({"#{@locale}" => @hash}.ya2yaml)
    end
    def get_key(value,path=nil)
      h = @hash
      path.each{|p| h[p] ||= {}; h = h[p] } if path
      return h.key(value)
    end
  end
end