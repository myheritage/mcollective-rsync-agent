module MCollective
  module Agent
    class Rsync<RPC::Agent
      action "rsync" do
        source = request.data[:source]
        destination = request.data[:destination]
        rsync_opts = request.data[:rsync_opts]
        if !request.data[:proxy_list].nil? && !request.data[:proxy_list].empty?
          rsync_proxies = request.data[:proxy_list].split(',')
        end
        if rsync_proxies.nil? || rsync_proxies.empty?
          command = [ "/usr/bin/rsync", rsync_opts, source, destination ].join(" ")
        else
          if !rsync_proxies.is_a?(Array)
            reply.fail! "Failed to parse the proxy list"
          else
            rand = Random.new(rsync_proxies.size)
            selected_proxy = rsync_proxies[rand.rand(rsync_proxies.size)]
            Log.debug("Selected proxy server: #{selected_proxy}")
            command = ["export RSYNC_PROXY=#{selected_proxy}", '&&' '/usr/bin/rsync', rsync_opts, source, destination ].join(' ')
          end
        end
        out = []
        err = ""
        rc = 1
        begin
          rc = run(command, :stdout => out, :stderr => err)
          if rc != 0
            Log.warn(command)
            Log.warn(err)
          else
            Log.debug(command)
            Log.debug(err)
          end
        rescue => error
          Log.fatal("Caught exception while running rsync: %s" % [error])
        end
        reply.fail! "Rsync failed!" unless rc == 0
        reply[:status] = "Rsync completed"
      end
    end
  end
end
