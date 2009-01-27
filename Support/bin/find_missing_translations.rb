#!/usr/bin/env ruby

require 'rails_bundle_tools'
require "#{ENV["TM_SUPPORT_PATH"]}/lib/escape"
require "#{ENV["TM_SUPPORT_PATH"]}/lib/web_preview"

require File.join(ENV["TM_PROJECT_DIRECTORY"], "config/environment")

counter = 0

puts html_head(:window_title => "Find Missing Translations", :page_title => 'Find Missing Translations', :sub_title => 'RakeMate')

puts <<-HTML
    <div id="report_title">Finding missing translations in Rails project.</div>
    <div><!-- Script output -->
			<pre>

<div style="white-space: normal; -khtml-nbsp-mode: space; -khtml-line-break: after-white-space;"> <!-- Script output -->
HTML

Dir.glob(File.join(ENV["TM_PROJECT_DIRECTORY"], "app/**/*.{rb,erb}")) do |file|
  line_counter = 0
  contains = false
  File.open(file).each do |line|
    line_counter += 1
    if found_translate_call = line.match(/(?:(?:\st|\.t)|translate)\((.*?)\)/i)
      begin
        translation_missing_error = Object.class_eval("I18n.translate(#{found_translate_call[1]})")
        if translation_missing_error.is_a?(Hash)
          counter += 1
          contains = true
          puts "<a href='txmt://open?url=file://#{file}&line=#{line_counter}'>Missing pluralization parameter in File: #{File.basename(file)}</a> Zeile #{line_counter}<br />"
        elsif translation_missing_error.match(/translation missing/)
          counter += 1
          contains = true
          puts "<a href='txmt://open?url=file://#{file}&line=#{line_counter}'>#{translation_missing_error} in File: #{File.basename(file)}</a> Zeile #{line_counter}<br />"
        end
      rescue SyntaxError => se
        puts "<a style=\"color: red\" href='txmt://open?url=file://#{file}&line=#{line_counter}'>Complex Translation found in File: #{File.basename(file)}.</a> Zeile #{line_counter}<br />"
      rescue NameError => ne
        puts "<a style=\"color: red\" href='txmt://open?url=file://#{file}&line=#{line_counter}'>Translation which uses variables has been found in File: #{File.basename(file)}.</a> Zeile #{line_counter}<br />"
      end
    end
  end
  puts "<br />" if contains
end


puts "<div><strong>#{counter}</strong> Zeilen gefunden</div>"
puts "<div class='done'>Done</div>"

puts <<-HTML
      </div>
    </div>
  </body>
</html>
HTML