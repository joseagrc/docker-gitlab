require 'docker'

class DockerOperations
  def self.build(location, image, tag)
    Docker.options[:read_timeout] = 600
    Docker::Image.build_from_dir(location.to_s, { t: "#{image}:#{tag}", pull: true }) do |chunk|
      if (log = JSON.parse(chunk)) && log.key?("stream")
        puts log["stream"]
      end
    end
  end

  def self.authenticate(username, password, serveraddress)
    Docker.authenticate!(username: username, password: password, serveraddress: serveraddress)
  end

  # namespace - registry project. Can be one of:
  # 1. gitlab/gitlab-{ce,ee}
  # 2. gitlab/gitlab-qa
  # 3. omnibus-gitlab/gitlab-{ce,ee}
  #
  # initial_tag - specifies the tag used while building the image. Can be one of:
  # 1. latest - for GitLab images
  # 2. ce-latest or ee-latest - for GitLab QA images
  # 3. any other valid docker tag
  #
  # new_tag - specifies the new tag for the existing image
  #
  # registry - specifies the target registry. Can be one of:
  # 1. docker.io
  # 2. gitlab.com
  # 3. dev.gitlab.org
  def self.push(namespace, initial_tag, new_tag, registry = 'docker.io')
    image = get(registry, namespace, initial_tag)
    tag_and_push(image, registry, namespace, new_tag)
  end

  def self.get(registry, namespace, tag)
    Docker::Image.get("#{registry}/#{namespace}:#{tag}")
  end

  def self.tag_and_push(image, registry, namespace, tag)
    registry_repository = "#{registry}/#{namespace}"
    image.tag(repo: registry_repository, tag: tag, force: true)
    image.push(Docker.creds, repo_tag: "#{registry_repository}:#{tag}") do |chunk|
      puts chunk
    end
  end
end
