class MCollective::Application::Rsync<MCollective::Application

      usage <<-END_OF_USAGE
mco rsync -s|--source <SOURCE> -d|--destination <DESTINATION> [-o|--rsync_opts <OPTIONS>] [-a|--atomic]

The OPTIONS can be one of the following:
  -s | --source SOURCE    - Dist the set version
  -d | --destination DEST - Base url of the download
  -o | --rsync_opts       - Rsync options
  -p | --rsync_proxies    - Proxies to pick from and use for the rsync

END_OF_USAGE

  description "Dists a package"

  option :source,
         :description => "The source",
         :arguments   => ["-s", "--source SOURCE"],
         :type        => String,
         :required    => true

  option :destination,
         :description => "The destination",
         :arguments   => ["-d", "--destination DEST"],
         :type        => String,
         :required    => true

  option :rsync_opts,
         :description => "Rsync options to use",
         :arguments   => ["-o", "--rsync_opts OPTS"],
         :type        => String,
         :required    => false

  option :rsync_proxies,
         :description => "Rsync proxies list to use",
         :arguments   => ["-p", "--rsync_proxies PROXIES"],
         :type        => String,
         :required    => false

  option :atomic,
         :description => "Atomic rsync",
         :arguments   => ["-a", "--atomic"],
         :type        => :bool,
         :required    => false

  # Validate configuration
  def validate_configuration(configuration)

  end

  def main
    mc = rpcclient("rsync")
    mc.ttl = 3600
#    mc.discover :verbose => true
    client_options = {}
    client_options[:source] = configuration[:source] if configuration[:source]
    client_options[:destination] = configuration[:destination] if configuration[:destination]
    client_options[:rsync_opts] = configuration[:rsync_opts] if configuration[:rsync_opts]
    client_options[:proxy_list] = configuration[:rsync_proxies] if configuration[:rsync_proxies]
    client_options[:atomic] = configuration[:atomic] if configuration[:atomic]


    succeeded = Array.new()
    failures = 0

    puts "Sending rsync command to servers"
    mc.rsync(client_options) do |response, simpleresponse|
      if response[:body][:statuscode] == 0
        printf("%-40s: %s\n", simpleresponse[:sender], simpleresponse[:data][:status])
        succeeded.push(simpleresponse[:sender])
      else
        puts "The RPC agent returned an error: #{response[:body][:statusmsg]}"
        failures += 1
      end

    end

    halt mc.stats
  end
end
