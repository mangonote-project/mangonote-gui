MANGONOTE_GUI_PATH=$(pwd)

docker run --rm -it -v $MANGONOTE_GUI_PATH:/mangonote-gui -w /mangonote-gui mangonote:build-env-linux sh -c 'make release-static -j4'
