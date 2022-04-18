app = search(:aws_opsworks_app).first
app_path = "/srv/#{app['shortname']}"

package "git" do
  # workaround for:
  # WARNING: The following packages cannot be authenticated!
  # liberror-perl
  # STDERR: E: There are problems and -y was used without --force-yes
  options "--force-yes" if node["platform"] == "ubuntu" && node["platform_version"] == "14.04"
end

application app_path do
  javascript "4"
  environment.update("PORT" => "80")
  environment.update(app["environment"])

  git app_path do
    repository app["app_source"]["url"]
    revision app["app_source"]["revision"]
    ssh_key app["app_source"]["ssh_key"]
  end

  link "#{app_path}/server.js" do
    to "#{app_path}/index.js"
  end

  npm_install do
    retries 3
    retry_delay 10
  end

  npm_start do
    action [:stop, :enable, :start]
  end
end