# MacRipper

Bulk rip icons, graphics and sounds from an HFS volume of a classic Mac OS into a directory, preserving the file hierarchy.

## Requirements

* [resource_dasm](https://github.com/fuzziqersoftware/resource_dasm)
* [hfsutils](https://www.mars.org/home/rob/proj/hfs/)
* [Convert::BinHex](https://metacpan.org/dist/Convert-BinHex)
* grep, sed

Most of them are usually available via package repositories, e.g. AUR.

## Usage

`MacRipper.sh /path/to/volume.hfv /path/to/output_folder`

Due to the number of files and folders created in the output, it's recommended to use something such as tmpfs.


