#!/bin/sh 
# Usage:
# 	./bin/cssflip.sh theme flavor path.css
rm -f app/assets/stylesheets/$1/tmp.*

#curl "http://localhost:3000/assets/$1/$2.css" > "app/assets/stylesheets/$1/tmp.1.css"
cp $3 "app/assets/stylesheets/$1/tmp.1.css"
./bin/cssflip.js "app/assets/stylesheets/$1/tmp.1.css"

sed 's/f105/f104/g' app/assets/stylesheets/$1/tmp.1.css.rtl > app/assets/stylesheets/$1/tmp.2.css.rtl

rm -f app/assets/stylesheets/$1/$2_rtl.css

cat "app/assets/stylesheets/$1/tmp.2.css.rtl" > "app/assets/stylesheets/$1/$2_rtl.css"

rm -f app/assets/stylesheets/$1/tmp.*