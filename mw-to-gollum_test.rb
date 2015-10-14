# encoding: UTF-8

require 'rubygems'
require 'hpricot'
require 'gollum'
require 'gollum-lib'
require 'optparse'
require 'git'
require 'chinese_pinyin'

all_title = "这是一个中文题目"
all = "\'\'\'[[Microduino Getting started]]\'\'\' \n \'\'\'[[Microduino Getting started/zh]]\'\'\' 中文 \n \'\'\'[[Microduino Getting started/en]]\'\'\' English \n 中文[[media:microduino1.jpg|100px|center|thumb]] English[[Media:microduino2.jpg|200px|left|thumb]] 中文[[file:microduino3.jpg|300px|right|thumb]] English[[File:microduino4.jpg|400px|top|thumb]] end "

puts "\n========= \n"

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

puts formatContext(all_title, all)