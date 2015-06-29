metadata  :name        => 'rsync',
          :description => 'Run rsync',
          :author      => 'Imri Zvik <imri.zvik@myheritage.com>',
          :version     => '0.0.1',
          :timeout     => 3600,
          :license     => 'Protected - MyHeritage LTD',
          :url         => "www.myheritage.com"

requires :mcollective => "2.2.1"


action "rsync", :description => "Parallel RSync" do
  display :always

  input  :source,
         :prompt      => "Rsync source",
         :description => "The source for the rsync",
         :display_as  => "Rsync source",
         :validation  => ".*",
         :type        => :string,
         :maxlength   => 0,
         :default     => "",
         :optional    => false

  input  :destination,
         :prompt      => "Rsync destination",
         :description => "The destination for the rsync",
         :display_as  => "Rsync destination",
         :validation  => ".*",
         :type        => :string,
         :maxlength   => 0,
         :default     => "",
         :optional    => false

  input  :rsync_opts,
         :prompt      => "Rsync options",
         :description => "List of rsync options to use",
         :display_as  => "Rsync options",
         :validation  => ".*",
         :type        => :string,
         :default     => "-avr",
         :maxlength   => 0,
         :optional    => true

  input  :proxy_list,
         :prompt      => "Proxy list",
         :description => "The rsync will pick a random proxy server to use",
         :display_as  => "Proxy list",
         :validation  => ".*",
         :type        => :string,
         :default     => "",
         :maxlength   => 0,
         :optional    => true

  output :status,
         :description => "The status of the dist",
         :display_as  => "status",
         :default     => "false"
end