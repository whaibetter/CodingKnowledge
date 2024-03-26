git add .
git commit -m "$(git status --porcelain)"
git push origin master
git push gitea master