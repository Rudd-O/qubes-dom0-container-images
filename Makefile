VERSIONS := 4.1
CLEAN := $(patsubst %, clean-%, $(VERSIONS))
DOCKERS := $(patsubst %, docker/qubes/%, $(VERSIONS))

.PHONY = $(DOCKERS) clean $(CLEAN)

clean: $(CLEAN)

clean-%:
	rm -rf $*/tree $*/snapshot.tar.gz

%/snapshot.tar.gz: %/*.cfg
	cd $* && mock -r qubes-$*-x86_64.cfg --init
	set -o pipefail ; cd $* && mock -r qubes-$*-x86_64.cfg --chroot \
	"bash -c 'cd / && tar -c --one-file-system --sparse --exclude=./var/cache/dnf/\"*\" .'" | pigz > snapshot.tar.gz || { ret=$$? ; rm -f snapshot.tar.gz ; exit $$ret ; }

%/tree: %/snapshot.tar.gz
	cd $* && mkdir -p .tree
	cd $* && sudo tar -xz -C .tree -f snapshot.tar.gz -v --exclude=./var/cache/dnf/"*" || { ret=$$? ; cd .. ; chmod -R u+rwX .tree ; rm -rf .tree ; exit $$ret ; }
	cd $* && if test -d tree ; then chmod -R u+rwX tree && rm -rf tree ; fi
	cd $* && mv .tree tree

docker/qubes/%: %/snapshot.tar.gz
	set -o pipefail ; cat $*/snapshot.tar.gz | podman image import -c "CMD /bin/sh -c /bin/sh" -c LABEL=architecture=x86_64 -c LABEL=com.github.containers.toolbox=true -c LABEL=com.github.debarshiray.toolbox=true -c LABEL=name=qubes -c LABEL=release=$* - qubes/$*
