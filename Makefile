INITRAMFS=clr-init-dm-verity.cpio.gz
DESTPATH=/usr/lib/initrd.d/

all:
	@./initramfs.sh $(INITRAMFS)

install: $(INITRAMFS)
	@mkdir -p $(DESTDIR)$(DESTPATH) && \
	cp $< $(DESTDIR)$(DESTPATH)

clean:
	@rm -rf initramfs && \
	rm $(INITRAMFS)
