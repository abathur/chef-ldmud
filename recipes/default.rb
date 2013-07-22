def get_ldmud_options()
  temp = []
  node[:ldmud][:options].sort.each do |key, val|
    if val == true
      temp.push("--"+key)
    elsif val == false
    else
      temp.push("--"+key+"="+val)
    end
  end
  return temp.join(" ")
end

git "/home/vagrant/ldmud" do
  repository "git://github.com/ldmud/ldmud.git"
  user "vagrant"
  if node[:ldmud].has_key?("version")
    resource node[:ldmud][:version]
  end
  action :sync
  notifies :run, "bash[config_ldmud]", :immediately
end

bash "config_ldmud" do
  user "vagrant"
  cwd "/home/vagrant/ldmud"
  flags "-lx"
  code <<-EOH
    bash autogen.sh
    autoconf autoconf/configure.in > configure
    ./configure #{get_ldmud_options()}
  EOH
  if node[:ldmud][:force_recompile] = true
    action :run
  else
    action :nothing
  end
  notifies :run, "bash[install_ldmud]", :immediately

end

bash "install_ldmud" do
  user "root"
  cwd "/home/vagrant/ldmud"
  flags "-lx"
  code <<-EOH
    make
    sudo make install-all
  EOH
  action :nothing
end

bash "run_ldmud" do
  user "vagrant"
  flags "-lx"
  code <<-EOH
    ldmud -m ~/#{node['ldmud']['mudlib']['name']} #{node['ldmud']['port']} --hostname #{node['ldmud']['hostname']} --hostaddr #{node['ldmud']['hostaddr']}
  EOH
  action :run
end
