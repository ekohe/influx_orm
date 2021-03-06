module InfluxORM
  class Connection
    attr_reader :config, :database, :client_config, :configuration

    def initialize(options, configuration)
      @config = options.with_indifferent_access
      @configuration = configuration
    end

    def db
      @db ||= InfluxDB::Client.new(config)
    end

    def query(sql)
      log(sql) { db.query(sql) }
    end

    def insert(table_name, point)
      log("INSERT to #{table_name}: #{point}") { db.write_point(table_name, point) }
    end

    def import(data)
      log("IMPORT #{data}") { db.write_points(data) }
    end

    private

    def log(log, &block)
      t = Time.now
      block.call
    ensure
      c = (Time.now - t) * 1000
      configuration.logger.info("[InfluxORM] (%.3f ms) %s" % [c, log])
    end
  end
end

