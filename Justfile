default:
    @just --list --unsorted

config := absolute_path('config')
build := absolute_path('.build')
out := absolute_path('firmware')
root := absolute_path('.')

_build shield:
    #!/usr/bin/env bash
    set -euo pipefail
    build_dir="{{ build / shield }}"

    west build -s zmk/app -d $build_dir -b nice_nano_v2 -- \
        -DBOARD_ROOT="{{ root }}" -DZMK_CONFIG="{{ config }}" -DSHIELD="{{ shield }}"

    mkdir -p "{{ out }}" && cp "$build_dir/zephyr/zmk.uf2" "{{ out }}/{{ shield }}.uf2"

build: (_build "hillside46_left") (_build "hillside46_right")
    @echo "Both sides built successfully"

_flash side:
    #!/usr/bin/env bash
    set -euo pipefail
    echo -n "Waiting for {{ side }}. Double tap reset button to flash."
    while ! device=$(lsblk -Sno path,model | grep -F 'nRF UF2' | cut -d' ' -f1); do
        echo -n "."
        sleep 1
    done
    echo -e "\nFound $device"
    tmp_mount=$(mktemp -d)
    sudo mount -o uid=1000,gid=1000 "$device" "$tmp_mount"

    size=$(stat -f %z "{{ out / side }}.uf2")
    pv -s $size "{{ out / side }}.uf2" > "$tmp_mount/{{ side }}.uf2"

    sudo umount "$tmp_mount"
    rm -rf "$tmp_mount"

    echo -n "Waiting for umount."
    while lsblk -Sno path,model | grep -F 'nRF UF2' > /dev/null; do
        echo -n "."
        sleep 1
    done
    echo "done"
    echo "Successfully flashed {{ side }}"

flash: (_flash "hillside46_left") (_flash "hillside46_right")
    @echo "Both sides flashed successfully"

clean:
    rm -rf {{ build }} {{ out }}
    rm -rf .west zmk

init:
    west init -l config
    west update --fetch-opt=--filter=blob:none
    west zephyr-export

update:
    west update --fetch-opt=--filter=blob:none
