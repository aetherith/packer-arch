.PHONY: all check clean

all:
	packer build -parallel-builds=1 arch.pkr.hcl

check:
	packer init .
	packer fmt .
	packer validate .

clean:
	rm -r build
