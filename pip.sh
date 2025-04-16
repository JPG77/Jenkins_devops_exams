i=`cat /tmp/nb`
x=$i+1
git add .

git commit -m "test final$x"
git push
echo $x >/tmp/nb
