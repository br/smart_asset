class SmartAsset
  module Helper
    def javascript_include_merged(*javascripts)
      JsStringBuilder.new.output_merged(*javascripts)
    end

    def stylehseet_link_merged(*stylesheets)
      StyleStringBuilder.new.output_merged(*stylesheets)
    end
  end
end

class StringBuilder
  attr_reader :filenames

  def output_merged(*filenames)
    @filenames = filenames
    append = SmartAsset.append_random ? "?#{rand.to_s[2..-1]}" : ''

    output = paths(*filenames, dir).collect { |file| build_string(file) }.join("\n")
    defined?(Rails) && Rails.version[0..0] == '3' ? output.html_safe : output
  end

  def paths
    filenames.collect { |file| SmartAsset.paths(dir, file) }.flatten.uniq
  end
end

class JsStringBuilder < StringBuilder
  def dir
    "javascripts"
  end

  def build_string(file)
    "<script src=\"#{SmartAsset.prepend_asset_host file}#{append}\"></script>"
  end
end

class StyleStringBuilder < StringBuilder
  def dir
    "stylesheets"
  end

  def build_string(file)
    options = filenames.last.is_a?(::Hash) ? filenames.pop : {}
    options[:media] ||= 'screen'
    "<link href=\"#{SmartAsset.prepend_asset_host file}#{append}\" media=\"#{options[:media]}\" rel=\"stylesheet\" />"
  end
end
