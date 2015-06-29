require 'fileutils'

module MCollective
  module Agent
    class Rsync<RPC::Agent
      action "rsync" do
        source = request.data[:source]
        destination = request.data[:destination]
        rsync_opts = request.data[:rsync_opts]

        if request.data[:atomic]
          # Atomic mode requested. Lets check if destdir is a symlink
            if !File.symlink?(destination)
              reply.fail! "Destination #{destination} is not a symlink!"
            end
            # Fix destination and add the --link-dest option to list of options
            link_dest = destination
            destination << "_#{Time.now}"
            if !rsync_opts.nil?
              rsync_opts << " --link-dest #{link_dest}"
            else
              rsync_opts = "--link-dest #{link_dest}"
            end
        end
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
        if rc == 0
          if request.data[:atomic]
            # We are in atomic mode, and rsync is successful
            # Time to swap the symlinks!
            old_dir = File.realpath(link_dest)
            FileUtils.ln_sf(destination,link_dest)
            FileUtils.remove_dir(old_dir)
          end
        reply[:status] = "Rsync completed"
        else
          if request.data[:atomic]
            # We are in atomic mode, and rsync failed.
            # Cleanup!
            FileUtils.remove_dir(destination)
          end
          reply.fail! "Rsync failed!"
        end

      end
    end
  end
end
