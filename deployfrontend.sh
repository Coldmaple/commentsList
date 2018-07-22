rsync -r src/ docs/
rsync build/contracts/ChainList.json docs/
git add .
git commit -m "Add frontend files to Github page"
git push origin master