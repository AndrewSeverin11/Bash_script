#!/bin/bash
clear
echo -e "\033[42m\033[30m\033[1m Подготовка системы к обновлению \033[0m\n"
cd /
iso_update=20211126SE16
iso_ext=.iso
iso_astra=AstraSmolenskAmd64.iso
#g_summ=120f9e73aa7e79a1ca4e858fe359db6601bf2b0909e57a52950dd65c988cecb9
n_dir=8
path_iso=(/mnt/ /mnt/hdd/Recovery/ /mnt/hdd/ $HOME/Загрузки/ $HOME/Документы/ $HOME/Документы/Recovery/ $HOME/Download/ $HOME"/Документы/Komplekt ARM/Recovery/")
#
sudo umount /media/cdrom*
sudo umount /dev/sr0
#
echo -e "\n\n\033[33;5;1m Проверка наличия файла обновления \033[0m\n\n"
a_indx=999
u_indx=999
indx=0
while [ $indx != $n_dir ];
    do
		   if [[ -d ${path_iso[$indx]} ]]
			then
				if [[ -e ${path_iso[$indx]}$iso_astra ]]
				then
			    		path_astra=${path_iso[$indx]}
                             		echo -e "\033[43;30m Файл установочного образа системы находится в  каталоге \033[34m${path_iso[$indx]}\033[0m\n"
			    		a_indx=$indx
				else
					echo -e "\033[31m В каталоге \033[42;30m ${path_iso[$indx]} \033[0;31m отсутствует установочный файл образа системы.\033[0m\n"
				fi
                                if [[ -e ${path_iso[$indx]}$iso_update$iso_ext ]]
                                then
                                         path_update=${path_iso[$indx]}
                                         echo -e "\033[43;30m Файл образа обновления системы находится в каталоге \033[34m${path_iso[$indx]} \033[0m\n"
                                         u_indx=$indx
                                else
                                         echo -e "\033[31m В каталоге \033[42;30m ${path_iso[$indx]} \033[0;31m отсутствует файл образа обновления системы\033[0m\n"
	                  	fi

			else
                               echo -e "\033[31m Отсутствует каталог для поиска \033[0m${path_iso[$indx]}\n"
		    fi
			indx=$((indx+1))
done
#
if [[ $a_indx = 999 ]]
then
echo -e "\033[41;30;5m ОБНОВЛЕНИЕНЕ НЕВОЗМОЖНО. ОТСУТСТВУЕТ ОБРАЗ УСТАНОВОЧНОГО ДИСКА ОПЕРАЦИОННОЙ СИСТЕМЫ \033[0m"
exit
else
sudo mkdir /media/cdrom0
sudo mount $path_astra$iso_astra /media/cdrom0
#
echo -e "\n\n\033[33;1m Подготовка репозитория \033[0m\n"
 
sudo mv /etc/apt/sources.list /etc/apt/sources.list.bak
sudo touch /etc/apt/sources.list
echo 'deb file:///media/cdrom0 smolensk contrib non-free main' | sudo sh -c 'cat >> /etc/apt/sources.list'
sudo apt clean && sudo apt update && sudo apt -y autoremove
echo -e "\n\n\033[42;30;1m Установка необходимых пакетов \033[0m\n"
sudo apt install -y libvulkan1 libev4 qdbus-qt5 libunwind8 reprepro libcurl3 qt5-image-formats-plugins ca-certificates
sudo apt install -y libxml++2.6-2v5 libxml-xpath-perl libxmlrpc-core-c3 libxmlrpc-epi0 libxml2 libxml-parser-perl
sudo apt -f install
fi

sudo -s <<EOF
mkdir /media/cdrom1
mount $path_update$iso_update$iso_ext /media/cdrom1
echo -e "\n\n\033[33;1m Подготовка репозитория \033[0m\n"
echo 'deb file:///media/cdrom1 smolensk contrib non-free main' | sh -c 'cat >> /etc/apt/sources.list'
apt update && astra-nochmodx-lock disable
echo -e "\n\n\033[33;1m Обновление операционной системы \033[0m\n"
apt -y dist-upgrade && apt -f install && astra-nochmodx-lock enable
echo -e "\n\n\033[42;30;1m Обновление операционной системы завершено.\033[0m \n\n"
exit
EOF
echo `uname -r`
echo -e "\n\n\033[33;1m Обновить ядро до версии 5.10?\033[0m"
echo -e "\n\033[33;1m Для подтверждения наберите - Yes(yes).\033[0m"
echo -e "\n\033[33;1m Если в данный момент обновление ядра не требуется, наберите - No или нажмите клавишу <Enter>.\033[0m \n"
read upkey
if [[ ${upkey} = 'Yes' || ${upkey} = 'yes' || ${upkey} = 'YES' || ${upkey} = 'y' || ${upkey} = 'Y' ]]
then
sudo -s <<EOF
apt update && apt install -y linux-5.10
EOF
s_load=(`grep -i "GRUB_DEFAULT=gnulinux" /etc/default/grub`)
r_load="s/$s_load/GRUB_DEFAULT=2/g"
sudo sed -i $r_load /etc/default/grub
sudo update-grub2
echo -e "\n\n\033[42;30;1m Ядро обновлено.\033[0m \n\n"
fi
sudo apt -y autoremove && sudo apt autoclean
sudo umount /media/cdrom*
sudo rm -R /media/cdrom1
sudo cp /etc/apt/sources.list.bak /etc/apt/sources.list
echo -e "\n\n\033[41;30;5m ОБЯЗАТЕЛЬНО ПЕРЕЗАГРУЗИТЕ КОМПЬЮТЕР.\033[0m \n\n"
exit
