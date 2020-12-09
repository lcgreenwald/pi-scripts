#/binbash
cd Downloads
wget http://www.hamqsl.com/solarrss.php
cat solarrss.php |grep solarflux >sflux.txt
cat solarrss.php |grep aindex >aindex.txt
sed -e 's/................/  /' sflux.txt > fluxout.txt
sed -r 's/.{12}$//' fluxout.txt >s-flux.txt
sed -e 's/............./  /' aindex.txt > aout.txt
sed -r 's/.{9}$//' aout.txt >a-index.txt
rm solarrss.php
rm sflux.txt
rm fluxout.txt
rm aindex.txt
rm aout.txt
cd
