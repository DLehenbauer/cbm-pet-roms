#!/bin/bash

# Function to compile assembly file and check size
compile_patch() {
    local source_file="$1"
    local output_file="$2"
    local expected_size="$3"
    local offset="$4"
    
    acme -r $output_file.txt "$source_file"
    
    local actual_size=$(stat --format=%s "$output_file")   
    if [ "$actual_size" -ne "$expected_size" ]; then
        echo ""
        echo "ERROR: Patch '$output_file' size mismatch! Expected $expected_size bytes, got $actual_size bytes."
        exit 1
    fi

    dd if=$output_file of=rom-1-e000-keyscan-fix.bin bs=1 seek=$(($offset)) conv=notrunc
    hexdump -v -e '1/1 "%02x"' $output_file
    echo ""
}

# Get original ROM file
cp ../../../originals/rom-1-e000.901447-05.bin rom-1-e000-keyscan-fix.bin

# Compile both patches
compile_patch "edit-1-patch-b-e702.s" "edit-1-patch-b-e702.bin" 170 "0x0702"
compile_patch "edit-1-patch-b-e7ec.s" "edit-1-patch-b-e7ec.bin" 20 "0x07ec"

## Check CRC-32 checksum
#crc=$(rhash --simple rom-1-e000-keyscan-fix.bin | awk '{print $1}')
#echo "CRC-32: $crc"
#echo "Original CRC-32: 9e1c5cea"
#
## Compare checksums
#if [ "$crc" = "9e1c5cea" ]; then
#    echo "✓ Checksum matches original ROM"
#else
#    echo "ERROR: Checksum mismatch!"
#    echo "Expected: 9e1c5cea"
#    echo "Got:      $crc"
#fi
