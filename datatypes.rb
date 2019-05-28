# Cell
class Cell
  attr_reader :neighbors
  attr_reader :fitness
  attr_reader :links
  attr_reader :dead
  attr_reader :x
  attr_reader :y

  def initialize sim,x,y
    @x=x
    @y=y
    @prob=0
    @timer=0
    @links=Hash.new
    getNeighbors sim
    @fitness=sim.fitness x,y
    @sprite=Circle.new(x: x,y: y,color: sim.color, radius: 15)
  end
  def update sim,dt
    @timer+=dt
    if @timer>=0.1 then
      mate sim if rand()<@prob
      @prob+=0.05
      @timer=0
    end
    for k,v in @links do
      if k.dead then
        @links.delete k
        v.remove
      end
    end
  end

  # Actions
  def die
    for k,v in @links do v.remove end
    for c in neighbors do
      c.links[self].remove if c.links[self]
      c.neighbors.delete self
    end
    @sprite.remove
    @dead=true
  end
  def mate sim,p: -1
    if @neighbors.length==0 then die else
      i=rand @neighbors.length
      if p==-1 then p=@neighbors[i] end
      chance=@fitness+p.fitness
      mx=[rand(2*sim.mutation)-sim.mutation,0][rand(2)]
      my=[rand(2*sim.mutation)-sim.mutation,0][rand(2)]
      x=if rand()*chance<@fitness then @x else p.x end
      y=if rand()*chance<@fitness then @y else p.y end
      x=[sim.length,[0,x+mx].max].min
      y=[sim.length,[0,y+my].max].min
      sim.cells.push Cell.new(sim,x,y)
      @dead=true
      if !p.dead then p.mate sim,p: self end
      die
    end
  end

  # Data
  def distance c
    Math.sqrt(((@x-c.x)**2)+((@y-c.y)**2))
  end
  def getNeighbors sim
    @neighbors=[]
    for c in sim.cells do
      if !c.dead && self!=c && distance(c)<=100 then
        @links[c]=Line.new(x1: @x,y1: @y,x2: c.x,y2: c.y,color: sim.color, width: 1)
        c.neighbors.push self
        @neighbors.push c
      end
    end
  end

  def == c
    self.class==c.class && @x==c.x && @y==c.y
  end
end

# Simulation
class Simulation
  attr_reader :mutation
  attr_reader :length
  attr_reader :color
  attr_reader :cells
  attr_writer :cells
  def initialize(color: "#63c0f2",mutation: 65,length: 400)
    @mutation=mutation
    @length=length
    @color=color
    @cells=[]
  end
  def update dt
    i=0
    while i<@cells.length do
      @cells[i].update self,dt
      @cells[i].die if @cells.count(@cells[i])>1
      if @cells[i].dead then @cells.delete_at i
      else i+=1 end
    end
  end
  def dead
    @cells.length==0
  end
  def fitness x,y
    c=@length/2
    100*(c-Math.sqrt(((x-c)**2)+((y-c)**2)))
  end
end
