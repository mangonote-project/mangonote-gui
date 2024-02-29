export GUI_PATH=$(pwd)

docker run --rm -it -v $GUI_PATH:/mangonote-gui -w /mangonote-gui mangonote:build-env-windows sh -c 'make depends root=/depends target=x86_64-w64-mingw32 tag=win-x64 -j4'
