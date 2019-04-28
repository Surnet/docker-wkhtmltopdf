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
  0.12.5 \
; do

  # edition small (contains only wkhtmltopdf) or full (with wkhtmltopdf, wkhtmltoimage and lib)
  for edition in \
    small \
    full \
  ; do

    # Supported base images
    for image in \
      alpine:3.9 \
      node:10.15.3-alpine \
      python:3.7.3-alpine3.9 \
    ; do
      # Parse image string
      base="${image%%:*}"
      baseVersion="${image##*:}"
      baseVersionClean="${baseVersion%%-*}"

      # Apply patch based on edition
      case "$edition" in
        small)
          replaceRules="
            /%%EDITION1%%/d;
            /%%EDITION2%%/d;
          "
        ;;
        full)
          replaceRules="
            s/%%EDITION1%%/COPY --from=builder \/bin\/wkhtmltoimage \/bin\/wkhtmltoimage/g;
            s/%%EDITION2%%/COPY --from=builder \/lib\/libwkhtmltox* \/bin\//g;
          "
        ;;
      esac

      # Check for base OS type (currently only alpine)
      case "$image" in
        alpine*)
          os="alpine"
          template="Dockerfile-alpine.template"
          replaceRules+="
            s/%%IMAGE%%/$image/g;
            s/%%WKHTMLTOXVERSION%%/$version/g;
            s/%%END%%/ENTRYPOINT [\"wkhtmltopdf\"]/g;
          "
        ;;
        *alpine*)
          os="alpine"
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

      case "$image" in
        alpine*)
          replaceRules+="
            s/%%BUILDER%%/$image/g;
          "
        ;;
        node*)
          replaceRules+="
            s/%%BUILDER%%/alpine:3.9/g;
          "
        ;;
        python*)
          replaceRules+="
            s/%%BUILDER%%/alpine:3.9/g;
          "
        ;;
        *)
          echo "WARNING: OS Type not supported"
          exit
        ;;
      esac

      # Prepare imageName and tag
      if [ "$os" == "$base" ]; then
        imageName="$base-wkhtmltopdf"
      else
        imageName="$os-$base-wkhtmltopdf"
      fi
      tag="$baseVersionClean-$version-$edition"
      dir="archive/$imageName"
      file="Dockerfile_$tag"

      # Build container if needed
      if ! docker_tag_exists "surnet/$imageName" "$tag"; then
        # Prepare Dockerfile
        mkdir -p "$dir"
        { generated_warning; cat "$template"; } > "$dir/$file"
        sed -i.bak -e "$replaceRules" "$dir/$file"

        # Build container
        echo "Starting build for surnet/$imageName:$tag"
        docker build . -f "$dir/$file" -t "surnet/$imageName:$tag" \
        && docker push "surnet/$imageName:$tag" \
        && echo "Successfully built and pushed surnet/$imageName:$tag" || echo "Building or pushing failed for surnet/$imageName:$tag"
      fi

    done

  done

done

wait
echo "###########################################################
  The script completed creating and pushing docker images
###########################################################"
