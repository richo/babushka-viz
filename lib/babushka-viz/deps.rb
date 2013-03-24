def load_deps(dep_dir)
  Dir["#{dep_dir}/**/*.rb"].each do |f|
    BabushkaVizSandbox.load_dep(f)
  end
end

module BabushkaVizSandbox extend self
  def load_dep(filename)
    puts filename
  end

  def dep(name, *args, &block)
    d = BabuskaVizStubDep.new(name)
    if block
      d.instance_exec(&block)
    end
  end

  class BabuskaVizStubDep
    def initialize(name)
      @name = name
      @dependencies = []
    end
    def requires(deps)
      case deps
      when String
        @dependencies << deps
      when Array
        deps.each { |d| @dependencies << d }
      else
        raise "Unhandled requires type #{deps.class}"
      end
    end

    def method_missing
    end
  end
end
