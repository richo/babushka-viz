FILE_READ = File.method(:read)

def load_deps(dep_dir)
  Dir["#{dep_dir}/**/*.rb"].each do |f|
    BabushkaVizSandbox.load_deps_from(f)
  end

  BabushkaVizSandbox.deps.each do |name, dep|
    dep.load
  end

  BabushkaVizSandbox.deps.each do |k, v|
    puts "#{k} :: #{v}"
  end
end

module BabushkaVizSandbox extend self
  def load_deps_from(filename)
    ruby = ::FILE_READ.call(filename)
    eval(ruby, binding, filename)
  end

  def dep(name, *args, &block)
    d = BabushkaVizStubDep.new(name, block)
    deps[name.freeze] = d
  end

  def meta(name, *args, &block)
    m = BabushkaVizStubMeta.new(name)
    # TODO evaluate meta for requires
    metas[name.freeze] = m
  end

  def deps
    @@deps ||= {}
  end

  def metas
    @@metas ||= {}
  end

  class BabushkaVizStubDep
    def initialize(name, block=nil)
      @name = name
      @block = block
      @dependencies = []
    end

    def load
      puts "called load for #{@name}"
      self.instance_exec(&@block) if @block
    end

    def requires(*deps)
      puts "called requires"
      deps.each do |d|
        case d
        when String
          @dependencies << d
        else
          raise "Unhandled requires type #{deps.class}"
        end
      end
    end

    def method_missing(sym, *args)
      return BlackHoleStub.new
    end

    def gem(*args)
      self
    end

    def to_s
      "<#{@name}> Requires: #{@dependencies}"
    end
  end

  class BabushkaVizStubMeta
    def initialize(name)
      @name = name
    end
  end
end

# Crimes against humanity to support Babushka
class String
  def with(*args)
    # TODO Stash this somewhere so we can track args in the graph
    self
  end

  def p
    # TODO consider actually doing something iwth paths
    self
  end

  def / other
    self
  end
end

class File
  def self.read(*args)
    ""
  end
  def self.expand_path(*args)
    ""
  end
end

class BlackHoleStub
  def self.method_missing(sym, *args)
    new
  end
  def method_missing(sym, *args)
    self
  end
  def read
    ""
  end
  def to_str
    ""
  end
end

alias :L :lambda

Babushka = BlackHoleStub
# :(
Babushka::ShellHelpers = Module.new
