export DOCKER_REPO := stefco/llama-dev
export DOCKERFILE_PATH := Dockerfile

.PHONY: help
help:
	@echo "Please use \`make <target>\` where <target> is one of:"
	@echo "  help           show this message"
	@echo "  37             Docker Cloud-style llama-dev:py37 image build"
	@echo "  push37         docker push llama-dev:py37"

# .PHONY: 36
# 36:
# 	$(eval export DOCKER_TAG := py36)
# 	hooks/build

.PHONY: 37
37:
	$(eval export DOCKER_TAG := py37)
	hooks/build

# .PHONY: push36
# push36:
# 	$(eval export DOCKER_TAG := py36)
# 	docker push $$DOCKER_REPO:$$DOCKER_TAG
# 	hooks/post_push

.PHONY: push37
push37:
	$(eval export DOCKER_TAG := py37)
	docker push $$DOCKER_REPO:$$DOCKER_TAG
	hooks/post_push
	docker tag $$DOCKER_REPO:$$DOCKER_TAG $$DOCKER_REPO:latest
	docker push $$DOCKER_REPO:latest
