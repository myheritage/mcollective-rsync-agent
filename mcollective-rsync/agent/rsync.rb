require 'fileutils'

module MCollective
  module Agent
    class Rsync<RPC::Agent
      action "rsync" do
        source = request.data[:source]
        destination = request.data[:destination]
        rsync_opts = request.data[:rsync_opts]
        Log.info("Starting with #{request.data.inspect}")
        link_dest = nil
        if request.data[:atomic]
          # Atomic mode requested. Lets check if destdir is a symlink
            if !File.symlink?(destination) && File.exists?(destination)
              reply.fail! "Destination #{destination} is not a symlink!"
            end
            if File.exists?("#{destination}_tmp")
              reply.fail! "Temporary symlink location #{destination}_tmp already exists!"
            end
            # Fix destination and add the --link-dest option to list of options
            link_dest = destination.dup
            destination << "_#{Time.now.to_i}"
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
          Log.info("Running rsync command: #{command}")
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
            Log.debug('Finished rsync, fixing links')
            if File.symlink?(link_dest)
              old_dir = Pathname.new(link_dest).realpath
            end
            begin
              atomic_symlink_switch(destination,link_dest)
            rescue => e
              reply.fail! "Failure in atomic symlink switch: #{e.message}"
            end
            if old_dir and !old_dir.nil?
              if Pathname.new(destination).realpath != Pathname.new(link_dest).realpath
                Log.error("#{link_dest} does not point to #{destination}")
                FileUtils.remove_dir(destination)
                reply.fail! "Failed to set link"
              end
              FileUtils.remove_dir(old_dir)
            end
          end
          reply[:status] = "Rsync completed"
        else
          if request.data[:atomic]
            # We are in atomic mode, and rsync failed.
            # Cleanup!
            Log.debug('Rsync failed, removing target dir without touching the link')
            FileUtils.remove_dir(destination) if File.exists?(destination)
            FileUtils.remove_dir("#{link_dest}_tmp") if File.exists?("#{link_dest}_tmp")
          end
          reply.fail! "Rsync failed!"
        end
        Log.info "Returning: #{reply[:status]}"
      end

      def atomic_symlink_switch(destination,link_dest)
        Log.info("Going to link #{destination} to #{link_dest}_tmp")
        lnrc = run("/bin/ln -nsf #{destination} #{link_dest}_tmp", :stdout => :out, :stderr => :err)
        if lnrc != 0
          Log.error("ln command returned error: #{err}")
          raise "ln command returned error: #{err}"
        end
        Log.info("Going to mv #{link_dest}_tmp into #{link_dest}")
        mvrc = run("/bin/mv -T #{link_dest}_tmp #{link_dest}", :stdout => :out, :stderr => :err)
        if mvrc != 0
          Log.error("mv command returned error: #{err}")
          raise "mv command returned error: #{err}"
        end
      end
    end
  end
end
