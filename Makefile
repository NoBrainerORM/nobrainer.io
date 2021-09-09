build:
	jekyll build

publish:
	@test -z "`git status --short`" || (echo "git is dirty"; exit 1)
	git branch -D gh-pages || true
	git checkout --orphan gh-pages
	ls | grep -v _site | xargs rm -rf
	mv _site/* .
	rm -rf _site Gemfile Gemfile.lock Guardfile .gitignore Makefile README.md
	git add .
	git commit -am 'Site'
	git push origin gh-pages:gh-pages -f
	git checkout master

with_docker:
	docker build . --tag local/nobrainer.io
	rm -rf _site
	docker run --rm local/nobrainer.io tar cf - _site | tar xf -
