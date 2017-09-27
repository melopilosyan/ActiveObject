require_relative "text-table"

table = Text::Table.new do |t|
  t.head = ['Heading A', 'Heading B', 'Heading C']
  t.rows << ['a1', {value: :b1, color: :red}, 'c1' ]
  t.rows << ['a2', 'b2', {value: :c2, color: :yellow}, {row_bg_color: :blue} ]
  t.rows << [{value: :a3, bgcolor: :red}, 'b3', 'c3' ]
  t.rows << [:a4, {value: :b4, color: :red}, :c4, {row_color: :cyan} ]
end


puts table

