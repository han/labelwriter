module CsvTools
  # skips lines until a line starts with first field
  # infers field separator
  # returns csv minus skipped lines, and separator
  def self.prep_csv(file, first_field)
    s = file.tempfile.readline until s =~ /^#{first_field}([,;\t])/
    s += file.tempfile.read
    s.force_encoding('iso-8859-1').encode!('utf-8')
    [s, $1]
  end
end
