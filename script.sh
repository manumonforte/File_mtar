#!/bin/bash

file=mytar

#comprobar que existe mytar
if [[ -f "$file" && -x "$file" ]]
then
  echo "existe"
else
  echo "no existe"
fi

#comprobar que existe temp
if [[ -d "tmp" ]]
then
  echo "borrando directorio tmp..."
  rm -rf tmp
  echo "directorio borrado"
fi

#crear temp y posicionarse en temp
echo "Creando tmp"
mkdir tmp && cd tmp

#crear ficheros
echo "Hello Word!" >> file1.txt
head /etc/passwd >> file2.txt
head -c 1024 /dev/urandom >> file3.dat

#invocar mytar y crear filetar.mtar
../mytar -c -f filetar.mtar file1.txt file2.txt file3.dat

#copiar en out el fichero filetar.mtar
mkdir out && cp filetar.mtar out

#ejecutar mytar
cd out && ../../mytar -x -f filetar.mtar

#comprobar el contenido de los ficheros
result1=$(diff file1.txt ../file1.txt)
result2=$(diff file2.txt ../file2.txt)
result3=$(diff file3.dat ../file3.dat)

if [[ "$result1"=="" && "$result2"=="" && "$result3"=="" ]]
then
  echo "los ficheros son iguales"
  echo "Correct"
  cd ../..
  exit 0
else
  echo "los ficheros tienen contenidos diferentes"
  cd ../..
  exit 1
fi

x=$(-k -f mytar.mtar | awk '{print $3}')

#comprobar el checksum de los ficheros
ck1=$(cksum file1.txt | awk '{print $1}')
ck2=$(cksum file2.txt | awk '{print $1}')
ck3=$(cksum file3.dat | awk '{print $1}')



$ck1 >> ck1.txt
$ck2 >> ck2.txt
$ck3 >> ck3.txt



if [[ "$ck1"==echo $x |awk '{print $1}' && "$ck2"==echo $x |awk '{print $2}'  && "$ck3"==echo $x |awk '{print $3}' ]]
then
  echo "los ficheros tienen el mismo cksum"
  echo "Correct"
  cd ../..
  exit 0
else
  echo "los ficheros tienen cksum diferentes"
  cd ../..
  exit 1
fi
