require "./datatypes.rb"
require "ruby2d"

s=Simulation.new length: 1000
x=0
while x<s.length do
  y=0
  while y<s.length do
    s.cells.push Cell.new(s,x,y)
    y+=100
  end
  x+=100
end
set title: "Nth-Dimensional Evolutionary Automata"
set width: s.length, height: s.length
set background: "white"
tick=1.0/60

dead=false
update do
  if !dead then
    s.update tick
    if s.dead then
      puts "All done"
      dead=true
    end
  end
end
show
