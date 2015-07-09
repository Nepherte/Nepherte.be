module Jekyll
  module IndentFilter
    def indent(content, indent = 0)
      output = []

      pre_regexp = /<\/?pre[^>]*>/i
      pre_list = content.scan(pre_regexp)
      blocks = content.split(pre_regexp)

      blocks.each_with_index do |block, i|
        if i.odd?
          output << block
        else
          # The first line should already be indented.
          output << block.lines.first
          block.lines.to_a[1..-1].each do |line|
            output << (' ' * indent.to_i) + line
          end
        end
        output << pre_list[i] if pre_list.size > i
      end
      output.join('')
    end
  end

  class IndentIncludeTag < Liquid::Tag
    include IndentFilter

    def initialize(tag_name, tag_data, tokens)
      super
      @tokens = tokens
      @file, @indent, *tag_data = tag_data.split(' ')
      @tag_data = tag_data.unshift(@file).join(' ')
      @indent ||= 0
    end

    def render(context)
      # Use the standard include tag to get the file contents.
      content = Jekyll::Tags::IncludeTag.new('include', @tag_data, @tokens).render(context)
      # Apply the indent filter (above).
      indent(content, @indent)
    end
  end
end

Liquid::Template.register_filter(Jekyll::IndentFilter)
Liquid::Template.register_tag('indent_include', Jekyll::IndentIncludeTag)