publish:
	jekyll build
	git branch -D gh-pages || true
	git checkout --orphan gh-pages
	ls | grep -v _site | xargs rm -rf
	mv _site/* .
	rm -rf _site Gemfile Gemfile.lock Guardfile .gitignore Makefile README.md
	git add .
	git commit -am 'Site'
	git push origin gh-pages:gh-pages -f
	git checkout master
