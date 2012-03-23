module ReadyForI18N
  class I18nGenerator
    EXTRACTORS = [ErbHelperExtractor, HtmlTextExtractor, HtmlAttrExtractor]
    PATH_PATTERN = /\/views\/(.*)/


    def self.dict
      @dict
    end

    def self.path
      @path
    end

    def self.excute(opt)
      setupOptions(opt)
      f = @src_path
      ReadyForI18N::ExtractorBase.i18n_namespace = file_path_to_message_prefix(f)
      @path = f.match(PATH_PATTERN)[1].gsub(/#{@ext}$/, '').split '/' if opt['dot'] && f =~ PATH_PATTERN
      result = EXTRACTORS.inject(File.read(f)) do |buffer, extractor|
        extractor.new.extract(buffer) { |k, v| @dict.push(k, v, @path) }
      end
      write_target_file(f, result) if @target_path

      @dict.write_to STDOUT
    end

    def self.file_path_to_message_prefix(file)
      segments = File.expand_path(file).split('/').select { |segment| !segment.empty? }
      subdir = %w(views helpers controllers models).find do |app_subdir|
        segments.index(app_subdir)
      end
      if subdir.nil?
        raise AppFolderNotFound, "No app. subfolders were found to determine prefix. Path is #{File.expand_path(file)}"
      end
      first_segment_index = segments.index(subdir) + 1
      file_name_without_extensions = segments.last.split('.')[0..0]
      path_segments = segments.slice(first_segment_index...-1)
      (path_segments + file_name_without_extensions).join('.')
    end

    private
    def self.setupOptions(opt)
      @src_path = opt['source']
      @locale = opt['locale']
      if opt['nokey']
        @dict = NoKeyDictionary.new(@locale)
      else
        @dict = LocaleDictionary.new(@locale)
        @target_path = opt['destination']
        if @target_path && (!@target_path.end_with? File::SEPARATOR)
          @target_path = "#{@target_path}#{File::SEPARATOR}"
        end
      end
      @ext = opt['extension'] || '.html.erb'
      ExtractorBase.use_dot(true) if opt['dot']
      if opt['keymap']
        files_content = opt['keymap'].split(':').map { |f| File.read(f) }
        ReadyForI18N::ExtractorBase.key_mapper = KeyMapper.new(*files_content)
      end

    end

    def self.write_target_file(source_file_name, content)
      full_target_path = File.dirname(source_file_name).gsub(@src_path, @target_path)
      FileUtils.makedirs full_target_path
      target_file = File.join(full_target_path, File.basename(source_file_name))
      File.open(target_file, 'w+') { |f| f << content }
    end
  end
end