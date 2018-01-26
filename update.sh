#!/bin/bash

trap killgroup SIGINT

function killgroup() {
  echo killing...
  kill 0
}

function generated_warning() {
	cat <<-EOH
		#
		# NOTE: THIS DOCKERFILE IS GENERATED VIA "update.sh"
		#
		# PLEASE DO NOT EDIT IT DIRECTLY.
		#

	EOH
}

function docker_tag_exists() {
  curl --silent -f -lSL https://index.docker.io/v1/repositories/$1/tags/$2 &> /dev/null
}

# wkhtmltopdf versions
for version in \
	0.12.4 \
; do

	# edition small (contains only wkhtmltopdf) or full (with wkhtmltopdf and lib)
	for edition in \
		small \
		full \
	; do

		# Supported base images
		for image in \
			alpine:3.6 \
			node:{8.9.4,9.4.0}-alpine \
			python:3.5.3-alpine \
		; do
      # Parse image string
			base="${image%%:*}"
			baseVersion="${image##*:}"
      baseVersionClean="${baseVersion%%-*}"
      if [ "${baseVersion##*-}" == "$baseVersion" ]; then
        os="$base"
      else
        os="${baseVersion##*-}"
      fi

      # Prepare imageName and tag
      if [ "$os" == "$base" ]; then
        imageName="surnet/$base-wkhtmltopdf"
      else
        imageName="surnet/$os-$base-wkhtmltopdf"
      fi
			tag="$baseVersionClean-$version-$edition"
			file="tmp/Dockerfile_$os-$base-$tag"

			# Apply patch based on edition
			case "$edition" in
				small)
					replaceRules="s/%%EDITION%%/\&\& patch -i \/tmp\/patches\/wkhtmltopdf-buildconfig.patch \\\/g;"
				;;
				full)
					replaceRules="/%%EDITION%%/d;"
				;;
			esac

			# Check for base OS type (currently only alpine)
			case "$image" in
				alpine*)
			    template="Dockerfile-alpine.template"
					replaceRules+="
						s/%%IMAGE%%/$image/g;
						s/%%WKHTMLTOXVERSION%%/$version/g;
						s/%%END%%/ENTRYPOINT [\"wkhtmltopdf\"]/g;
					"
			  ;;
			  *alpine*)
			    template="Dockerfile-alpine.template"
					replaceRules+="
						s/%%IMAGE%%/$image/g;
						s/%%WKHTMLTOXVERSION%%/$version/g;
						/%%END%%/d;
					"
			  ;;
				*)
			    echo "WARNING: OS Type not supported"
					exit
			  ;;
			esac

			# Prepare Dockerfile
			mkdir -p "tmp"
			{ generated_warning; cat "$template"; } > "$file"
			sed -i.bak -e "$replaceRules" "$file"

			# Build container if needed
			if ! docker_tag_exists "$imageName" "$tag"; then
				echo "Starting build for $imageName:$tag"

				docker build . -f "$file" -t "$imageName:$tag" \
        && docker push "$imageName:$tag" \
        && echo "Successfully built and pushed $imageName:$tag" || echo "Building or pushing failed for $imageName:$tag"
			fi

		done

	done

done

wait
echo "###########################################################
  The script completed creating and pushing docker images
###########################################################"
