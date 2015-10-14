# encoding: UTF-8

require 'rubygems'
require 'hpricot'
require 'gollum'
require 'gollum-lib'
require 'optparse'
require 'git'
require 'chinese_pinyin'

# Parse command line options

# ToDo: Make command line options mandatory
options = {}
OptionParser.new do |opts|
  opts.banner = 'Usage: ruby mw-to-gollum.rb --file input-file.xml --directory new.wiki'
  opts.on('-f FILE', '--file FILE', 'MediaWiki export file to import') do |v|
    options[:file] = v
  end
  opts.on('-d DIRECTORY', '--directory DIRECTORY', 'Destination directory in which to create a new Gollum wiki') do |v|
    options[:destination] = v
  end
end.parse!

# ======================================
# Handle content
$langs = ["zh", "en", "jp", "kr", "ko"]

$px_pattern = /\|(\d+)px\|/
$align_pattern = /\|(top|left|center|right|bottom)\|/

$file_pattern = /\[\[([Ff])ile:(.*?)\]\]/
$media_pattern = /\[\[([Mm])edia:(.*?)\]\]/
$link_pattern = /'''\[\[(.*?)\]\]'''/

def formatLink(title)
  name, match, lang = title.rpartition('/')
  # puts name, match, lang

  if $langs.include?(lang)
    return "#{lang}/#{Pinyin.t(name, splitter:' ')}|#{name}"
  end

  return "#{Pinyin.t(title, splitter:' ')}|#{title}"
end

def formatTitle(title)
  name, match, lang = title.rpartition('/')
  # puts name, match, lang

  if $langs.include?(lang)
    return "#{lang}/#{Pinyin.t(name, splitter:' ')}"
  end

  return Pinyin.t(title, splitter:' ')
end

def formatContext(title, content)
  ctx = content

  # process image size
  pxs = ctx.scan($px_pattern)
  pxs.each do |px|
    temp = px.join("")
    ctx.gsub!(/\|#{Regexp.escape(temp)}px\|/, "|width=#{temp}px|")
  end

  # process image aligh
  aligns = ctx.scan($align_pattern)
  aligns.each do |align|
    temp = align.join("")
    ctx.gsub!(/\|#{Regexp.escape(temp)}\|/, "|align=#{temp}|")
  end

  # process page link
  links = ctx.scan($link_pattern)
  links.each do |link|
    temp = link.join("")
    ctx.gsub!(/'''\[\[#{Regexp.escape(temp)}\]\]'''/, "[[#{formatLink(temp)}]]")
  end

  # process file link
  files = ctx.scan($file_pattern)
  files.each do |file|
    temp = file[1]
    ctx.gsub!(/\[\[([Ff])ile:#{Regexp.escape(temp)}\]\]/, "[[/upload/#{temp}]]")
  end

  # process media link
  medias = ctx.scan($media_pattern)
  medias.each do |media|
    temp = media[1]
    ctx.gsub!(/\[\[([Mm])edia:#{Regexp.escape(temp)}\]\]/, "[[/upload/#{temp}]]")
  end

  name, match, lang = title.rpartition('/')
  return "<!-- --- title: #{name} -->\n#{ctx}"
end
# ======================================

# Open the input file and create the output repo if it doesn't already exist

file = File.open(options[:file], 'r')
git = Git.init(options[:destination])
wiki = Gollum::Wiki.new(options[:destination])
doc = Hpricot(file)

# Get the Git user name and email
name = git.config('user.name')
email = git.config('user.email')

# Loop through each page in the MediaWiki dump file and create a new page in the Gollum wiki
doc.search('/mediawiki/page').each do |el|
  title = el.at('title').inner_text
  content = el.at('text').inner_text
  commit = {:message => "Import MediaWiki page #{title} into Gollum",
            :name => name,
            :email => email}
  begin
    if !(title.start_with?('File:') || title.start_with?('file:') || title.start_with?('Media:') || title.start_with?('media:'))
      # handle the files name of chinese
      c_title = formatTitle(title)

      puts "Writing page #{title} ＝> #{c_title}"

      # process image files & link
      # handle the files and medias in mediawiki
      wiki.write_page(c_title, :mediawiki, formatContext(title, content), commit)
    end
  rescue Gollum::DuplicatePageError
    puts "Duplicate #{c_title}"
    # rescue Encoding::CompatibilityError
    #   puts "Encoding Error: #{c_title}"
  end
end

file.close