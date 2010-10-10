desc "Update contributors list in README"
task :update_contributors do
  all_names = `git shortlog -s |cut -s -f2`
  distinct_names = all_names.gsub!(/\sand\s/, "\n").split("\n").uniq!.sort!

  # Remove gem owners and known names inconsistencies
  distinct_names.delete("Tom Kersten")
  distinct_names.delete("Leah Rieger")

  readme_file_contents = `cat README.txt`

  # Remove existing Contributors section
  readme_file_contents.sub!(/== Contributors(.|\n)*/, '')

  print "Updating 'Contributors' section of README..."
  File.open("README.txt", "w+") do |file|
    file.puts readme_file_contents
    file.puts "== Contributors (sorted alphabetically)"
    file.puts ""
    distinct_names.each {|name| file.puts "* #{name}"}
  end
  puts "done!"
end
