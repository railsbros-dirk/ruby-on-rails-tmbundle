#!/usr/bin/env ruby

require 'rails_bundle_tools'
require "#{ENV["TM_SUPPORT_PATH"]}/lib/escape"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/web_preview"

require File.join(ENV["TM_PROJECT_DIRECTORY"], "config/environment")

puts html_head(:window_title => "Find Missing Translations", :page_title => 'Find Missing Translations', :sub_title => 'RakeMate')

puts <<-HTML
    <div id="report_title">Finding missing translations in Rails project.</div>
    <div><!-- Script output -->
			<pre>

<div style="white-space: normal; -khtml-nbsp-mode: space; -khtml-line-break: after-white-space;"> <!-- Script output -->
HTML

counter = 0

puts "<h1>Scope Missing</h1>"

Dir.glob(File.join(ENV["TM_PROJECT_DIRECTORY"], "app/**/*.{rb,erb}")) do |file_name|
  contains = false
  file = File.open(file_name)
  file.each do |line|
    unless line =~ /#DONE/
      if line.index(' t(:message')
        counter += 1
        contains = true
        puts "<a href='txmt://open?url=file://#{file_name}&line=#{file.lineno}'>Missing Scope in File: #{File.basename(file_name)}</a> Zeile #{file.lineno}<br />"
      end
    end
  end
  puts "<br />" if contains
end
puts "<div>#{counter} Zeilen gefunden</div>"

puts "<br />"
puts "<hr />"
puts "<br />"

counter = 0

puts "<h1>Translation Missing</h1>"

Dir.glob(File.join(ENV["TM_PROJECT_DIRECTORY"], "app/**/*.{rb,erb}")) do |file_name|
  contains = false
  file = File.open(file_name)
  file.each do |line|
    if found_translate_call = line.match(/(?:(?:\st|\.t)|translate)\((.*?)\)/i)
      begin
        translation_missing_error = Object.class_eval("I18n.translate(#{found_translate_call[1]})")
        if translation_missing_error.is_a?(Hash)
          counter += 1
          contains = true
          puts "<a href='txmt://open?url=file://#{file_name}&line=#{file.lineno}'>Missing pluralization parameter in File: #{File.basename(file_name)}</a> Zeile #{file.lineno}<br />"
        elsif translation_missing_error.match(/translation missing/)
          counter += 1
          contains = true
          puts "<a href='txmt://open?url=file://#{file_name}&line=#{file.lineno}'>#{translation_missing_error} in File: #{File.basename(file_name)}</a> Zeile #{file.lineno}<br />"
        end
      rescue SyntaxError => se
        unless line =~ /#DONE/
          contains = true
          counter += 1
          puts "<a style=\"color: red\" href='txmt://open?url=file://#{file_name}&line=#{file.lineno}'>Complex Translation found in File: #{File.basename(file_name)}.</a> Zeile #{file.lineno}<br />"
        end
      rescue NameError => ne
        unless line =~ /#DONE/
          contains = true
          counter += 1
          puts "<a style=\"color: red\" href='txmt://open?url=file://#{file_name}&line=#{file.lineno}'>Translation which uses variables has been found in File: #{File.basename(file_name)}.</a> Zeile #{file.lineno}<br />"
        end
      end
    end
  end
  puts "<br />" if contains
end

puts "<div><strong>#{counter}</strong> Zeilen gefunden</div>"

puts "<br />"
puts "<div class='done'>Done</div>"

puts <<-HTML
      </div>
    </div>
  </body>
</html>
HTML