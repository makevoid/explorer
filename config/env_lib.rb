class Env

  def self.load!
    env_glob = File.read "#{APP_PATH}/.env"
    env_loc  = File.read "#{APP_PATH}/.env.local"
    env_glob = parse_env env_glob
    env_loc  = parse_env env_loc
    @@env = env_glob.merge env_loc
  end

  def self.[](key)
    env = ENV[key]
    return env if env && !env.empty?
    env = @@env[key]
    return env if env && !env.empty?
    raise "ENV VAR not found: #{key.inspect}" unless var
    var
  end

  private

  def self.parse_env(env)
    vars = {}
    env.split("\n").compact.each do |line|
      key, val = line.split("=").map &:strip
      vars[key] = val if val && !val.empty?
    end
    vars
  end

end
