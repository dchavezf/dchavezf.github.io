# Responsive Tables Plugin
# Converts tables to mobile-friendly cards on small screens
# Adds data-label attributes to table cells for use in ::before pseudo-elements

require 'nokogiri'

module Jekyll
  module ResponsiveTablesPlugin
    class TableConverter
      def self.process(html)
        return html if html.nil? || !html.include?('<table')

        doc = Nokogiri::HTML::DocumentFragment.parse(html)

        doc.css('table').each do |table|
          # Extract headers from thead
          headers = []
          table.css('thead th').each do |th|
            headers << th.text.strip
          end

          # Add data-label to tbody cells
          table.css('tbody td').each_with_index do |td, index|
            row_index = index / headers.length
            col_index = index % headers.length

            if col_index < headers.length
              td['data-label'] = headers[col_index]
            end
          end
        end

        doc.to_html
      end
    end
  end
end

# Hooks to process tables in posts and pages
Jekyll::Hooks.register :posts, :post_convert do |post|
  post.output = Jekyll::ResponsiveTablesPlugin::TableConverter.process(post.output)
end

Jekyll::Hooks.register :pages, :post_convert do |page|
  page.output = Jekyll::ResponsiveTablesPlugin::TableConverter.process(page.output)
end
