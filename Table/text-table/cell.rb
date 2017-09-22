module Text #:nodoc:
  class Table
    class Cell
  require "colorize"   


      # The object whose <tt>to_s</tt> method is called when rendering the cell.
      #
      attr_accessor :value
      
      # Text alignment.  Acceptable values are <tt>:left</tt> (default),
      # <tt>:center</tt> and <tt>:right</tt>
      #
      attr_accessor :align

      # Positive integer specifying the number of columns spanned
      #
      attr_accessor :colspan
      attr_reader :row #:nodoc:
      attr_accessor :bgcolor
      
      
      def initialize(options = {}) #:nodoc:
        @value  = options[:value].to_s
        @row     = options[:row]
        @align   = options[:align  ] || :left
        @colspan = options[:colspan] || 1
        @callback = options[:color] || :to_s
	      @bgcolor = options[:bgcolor]
      end

      def to_s #:nodoc:
      val_str = case align
        when :left
          value.ljust cell_width
        when :right
          value.rjust cell_width
        when :center
          value.center cell_width
      end

      val_str.send(@callback)

      if @bgcolor.nil?
        ([' ' * table.horizontal_padding]*2).join val_str
      else
        ([' ' * table.horizontal_padding]*2).join(val_str).colorize(:background => @bgcolor)
      end
      end

      def table #:nodoc:
        row.table
      end

      def column_index #:nodoc:
        row.cells[0...row.cells.index(self)].map(&:colspan).inject(0, &:+)
      end

      def cell_width #:nodoc:
        (0...colspan).map {|i| table.column_widths[column_index + i]}.inject(&:+) + (colspan - 1)*(2*table.horizontal_padding + table.horizontal_boundary.length)
      end

    end
  end
end
