
git add -A
git commit -m 'deploy'
git push origin butterfly

hexo generate
hexo deploy
pause