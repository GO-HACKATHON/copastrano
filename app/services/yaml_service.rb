class YamlService
	def generate(deployment_id, container_id, image_tag, new_image_tag)
		deployment = Deployment.find(deployment_id)
		Rails.logger.info(deployment)

		container = Container.find(container_id)
		Rails.logger.info(container)

		yml_file = deployment.newest_yml_file	

		# unix_time = Time.now.to_i
		# Rails.logger.info(unix_time)

		yaml_file = YAML.load_file(yml_file.yml_path)
		Rails.logger.info(yaml_file)

		containers = yaml_file['spec']['template']['spec']['containers']
		Rails.logger.info(containers)

		# image_name = container.image.split(':')[0]
		# new_image_tag = "#{image_name}:#{unix_time}"
		Rails.logger.info(new_image_tag)

		containers.map do |c|
			if c["image"].split(":")[0] == image_tag.split(":")[0]
				c["image"] = new_image_tag
			end
			c
		end
		Rails.logger.info(containers)

		yaml_file['spec']['template']['spec']['containers'] = containers
		Rails.logger.info(yaml_file)

		directory = "#{ENV['YML_DIR']}/#{deployment.id}"
		unix_time = Time.now.to_i
		file_name = "deployment-#{unix_time}.yml"
    path = File.join(directory, file_name)
    File.open(path, "wb") { |f| f.write(yaml_file.to_yaml) }

    yaml = deployment.yml_files.create({'yml_path': path})
    Rails.logger.info(yaml)

    yaml_file
	end
end