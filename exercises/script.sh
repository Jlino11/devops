#!/bin/bash

SCM=git
PACK=apache2
REPO="devops-static-web"
LINE="#########################################################################################"

echo $LINE
echo "Actualizando repos"
echo $LINE
apt update -y

echo $LINE
if dpkg -l |grep -q $PACK ;
then
  echo "Paqueteria requerida ya se encuentra instalada"
  echo $LINE
else
  echo "Instalando paqueteria requerida"
  apt install -y $PACK
  echo $LINE
  echo "Iniciando $PACK"
  systemctl start $PACK
  echo "Habilitando autostart"
  systemctl enable $PACK
fi

echo $LINE
if dpkg -l |grep -q $SCM
then
  echo "Paqueteria $SCM ya se encuentra instalada"
  echo $LINE
else
  echo "Instalando paqueteria faltante $SCM"
  echo $LINE
  apt install -y $SCM
  echo $LINE
  echo "Iniciando $SCM"
  systemctl start $SCM
  echo $LINE
  echo "Habilitando autostart"
  systemctl enable $SCM 
fi 

echo $LINE
if [ -d "$REPO" ] ;
then
  echo "la carpeta $REPO existe"
else
  echo "Descargando $REPO"
  echo $LINE
  git clone -b devops-mariobros https://github.com/roxsross/$REPO.git
fi

echo $LINE
echo "Instalando web"
sleep 1
echo $LINE
cp -r $REPO/* /var/www/html/

echo "Script finalizado"
echo $LINE
