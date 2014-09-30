def embedded_svg filename, options={}
  file = File.read(File.join('assets', 'images', filename))
  doc = Nokogiri::HTML::DocumentFragment.parse file
  svg = doc.at_css 'svg'
  if !options[:class].nil?
    svg['class'] = options[:class]
  end
  doc.to_html
end
