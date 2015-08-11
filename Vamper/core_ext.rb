class String
  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr('-', '_').
        downcase
  end

  def replace_tags!(tags)
    tags.each { |name, value|
      self.gsub!(%r(\$\{#{name.to_s}\})m, value)
    }
    self
  end
end