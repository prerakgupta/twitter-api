
CONFIG = YAML.load(File.read("#{File.dirname(__FILE__)}/keys.yml"))
CONFIG["db"] = YAML.load(File.read("#{File.dirname(__FILE__)}/../database.yml"))[CONFIG["env"]["name"]]

ADMIN = "Prerak"

NOTIFICATION_EMAIL = "g.prerak@sprinklr.com"