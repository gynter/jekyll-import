module JekyllImport
  module Importers
    class CSV < Importer
      def self.require_deps
        JekyllImport.require_with_fallback(%w[
          csv
          fileutils
        ])
      end

      def self.specify_options(c)
        c.option 'file', '--file NAME', 'The CSV file to import (default: "posts.csv")'
        c.option 'no-front-matter', '--no-front-matter', 'Do not add the default front matter to the post body'
      end

      # Reads a csv with title, permalink, body, published_at, and filter.
      # It creates a post file for each row in the csv
      def self.process(options)
        file = options.fetch('file', "posts.csv")

        FileUtils.mkdir_p "_posts"
        posts = 0
        abort "Cannot find the file '#{file}'. Aborting." unless File.file?(file)

        ::CSV.foreach(file) do |row|
          next if row[0] == "title"
          posts += 1
          name = build_name(row)
          write_post(name, row[0], row[2], options)
        end
        "Created #{posts} posts!"
      end

      def self.write_post(name, title, content, options)
        File.open("_posts/#{name}", "w") do |f|
          write_frontmatter(f, title, options)
          f.puts content
        end
      end

      def self.build_name(row)
        row[3].split(" ")[0]+"-"+row[1]+(row[4] =~ /markdown/ ? ".markdown" : ".textile")
      end

      def self.write_frontmatter(f, title, options)
        no_frontmatter = options.fetch('no-front-matter', false)
        unless no_frontmatter
          f.puts <<-HEADER
---
layout: post
title: #{title}
---
HEADER
        end
      end
    end
  end
end
