module Text #:nodoc:
  class Table

    # A Text::Table::Row belongs to a Text::Table object and can have many Text::Table::Cell objects.
    # It handles the rendering of rows and inserted separators.
    #
    class Row
      attr_reader :table #:nodoc:
      attr_reader :cells #:nodoc:

      def initialize(row_input,table) #:nodoc:
        @table = table
        row_input = [row_input].flatten
        cell_color = :to_s

        row_input.delete_at -1 if row_input.last.kind_of?(Hash) && 
              ((@bg_color = row_input.last[:row_bg_color]) || (cell_color = row_input.last[:row_color]))

        @cells = row_input.first == :separator ? :separator : row_input.map do |cell_input|
          Cell.new(cell_input.is_a?(Hash) ?
                   cell_input.merge(:row => self).merge(color: cell_color) {|_, ov, _| ov} :
                   {:value => cell_input, :row => self, color: cell_color})
        end
      end

      def to_s #:nodoc:
        if cells == :separator
          table.separator
        else
          ([table.horizontal_boundary] * 2).join(
            (line = cells.map(&:to_s).join(table.horizontal_boundary)) && @bg_color ?
              line.colorize(background: @bg_color) : line
          ) + "\n"
        end
      end

    end
  end
end
