#!/bin/bash

version="v1.1"
name="patente-pendiente"
modificado="13/11/2019"

# =========================================================== #
#          INSSIDE LAB - ANALISIS DE SEGMENTACION             #
# =========================================================== #
#                                                             #
# Este script surge de la necesidad de realizar los analisis  #
# de segmentacion de manera mas automatica                    #
#                                                             #
# Por favor avisar por cualquier bug o sugerencias de nuevas  #
# funcionalidades.                                            #
# Y si a alguien se le ocurre un buen nombre avise tambien!   #
#                                                             #
# Gracias!!                                                   #
#                                                             #
# Desarrolado por: Federico Galarza                           #
# Banner y colores por: Omar Peña                             #
#                                                             #
# =========================================================== #
#                    Comienzo del script                      #
# =========================================================== #

## Variables
fecha="$(date +"%d/%m/%Y")"
hora="$(date +"%H:%M:%S")"
fecha_log="$(date +"%d%m%Y")"
hora_log="$(date +"%H%M")"

## parametros de entrada
input="${!#}"
param_1="$1"
param_2="$2"

## archivos de outputs
icmp_log="icmp-$hora_log"_"$fecha_log.log"

tcp_grep_100="tcp_100-$hora_log"_"$fecha_log.gnmap"
tcp_grep_1000="tcp_1000-$hora_log"_"$fecha_log.gnmap"
tcp_grep_all="tcp_all-$hora_log"_"$fecha_log.gnmap"

tcp_log_100="tcp_100-$hora_log"_"$fecha_log.log"
tcp_log_1000="tcp_1000-$hora_log"_"$fecha_log.log"
tcp_log_all="tcp_all-$hora_log"_"$fecha_log.log"

udp_grep_100="udp_100-$hora_log"_"$fecha_log.gnmap"
udp_grep_1000="udp_1000-$hora_log"_"$fecha_log.gnmap"
udp_grep_all="udp_all-$hora_log"_"$fecha_log.gnmap"

udp_log_100="udp_100-$hora_log"_"$fecha_log.log"
udp_log_1000="udp_1000-$hora_log"_"$fecha_log.log"
udp_log_all="udp_all-$hora_log"_"$fecha_log.log"

## temporales
filt_tmp="filt.tmp"
list_tmp="lista-redes.tmp"

##Colores
B="\e[94m"		#Azul
R="\e[31m" 		#ROJO
W="\e[39m" 		#Blanco default
G="\e[38;5;82m"	#Verde
C="\e[38;5;45m"	#cyan
S="\e[4m"		#subrayado
S2="\e[24m"		#Quitar subrayado
Y="\e[38;5;3m" 	#amarillo
b="\e[1m" 		#bold
NF="\e[0m"		#quitar formato


## Banners y mensajes

function banner(){	

	echo -e "$b
  ===========================================================
           INSSIDE LAB - ANALISIS DE SEGMENTACION	\e[5m$version\e[0m$b
  ===========================================================
 
     +----------+      
     ╏  NO PCI  ╏<-+   "$R"╔══════════╗      "$B"╔═══════════════╗"$W"
     +----------+  │   "$R"║"$W" ╌ ╌ ╌ ╌  "$R"║      "$B"║               ║"$W"
                   +-->"$R"╬"$W"  ╌ ╌ ╌ ╌ "$R"║"$W"  ┌──►"$B"╣   "$W"PCI - DSS"$B"   ║"$W"
     +----------+      "$R"║"$W" ╌ ╌ ╌ ╌  "$R"╬"$W"◄─┘   "$B"║               ║"$W"
     ╏  NO PCI  ╏<---->"$R"╬ "$W"FIREWALL"$R" ║      "$B"╚═══════════════╝"$W"
     +----------+      "$R"║"$W"  ╌ ╌ ╌ ╌ "$R"╬"$W"◄─┐
                   +-->"$R"╬"$W" ╌ ╌ ╌ ╌  "$R"║"$W"  │   "$B"╔═══════════════╗"$W"
     +----------+  │   "$R"║"$W"  ╌ ╌ ╌ ╌ "$R"║"$W"  └──►"$B"╣  "$W"PCI 💳 💳 💳"$B" ║"$W"
     ╏  NO PCI  ╏<-+   "$R"╚══════════╝      "$B"╚═══════════════╝"$W"
     +----------+
  ===========================================================
  $NF"
}

function banner_inicio (){
	tipo="$param_1"
	if [  "$tipo" == "-icmp"  ]; then
		tipo="ICMP"
		echo -e "$b$C  Comenzando analisis $tipo:$W $fecha a las $hora"
		echo ""
	elif [ "$tipo" == "-tcp" ]; then
		tipo="TCP"
		echo -e "$b$C  Comenzando analisis $tipo:$W $fecha a las $hora"
		echo ""
	elif [  "$tipo" == "-udp"  ]; then
		tipo="UDP"
		echo -e "$b$C  Comenzando analisis $tipo:$W $fecha a las $hora"
		echo ""
	fi
}

function banner_fail (){
	echo -e "
$C$b  Analisis completo:$W $fecha a las $hora
 $W
  +───────────────────────────────────+
  │                                   │
  │    El analisis ha dado $R FAIL ✘$W    │  
  │                                   │  
  +───────────────────────────────────+
 $NF"
}

function banner_pass(){
	echo -e "
$C$b  Analisis completo:$W $fecha a las $hora
 $W
  +───────────────────────────────────+
  │                                   │
  │    El analisis ha dado $G PASS ✔$W    │  
  │                                   │  
  +───────────────────────────────────+
  $NF"
}

function help_menu (){
	banner
	echo -e "$b
  $name en una herramienta que automatiza la ejecucion de los analisis de segmentacion.
  
 "$S$C"Opciones$S2:
$NF$W
	$b-icmp$NF$W	Realiza el analisis basado en protocolo ICMP.
	$b-tcp$NF$W	Realiza el analisis basado en protocolo TCP, utilizar con parametros F, N y all.
	$b-udp$NF$W	Realiza el analisis basado en protocolo UDP, utilizar con parametros F, N y all..
	
	"$b"F$NF$W	Se realizan las pruebas sobre 100 puertos comunes.
	"$b"N$NF$W	Se realizan las pruebas sobre 1000 puertos comunes.
	"$b"all$NF$W	Se realizan las pruebas sobre los 65535 puertos.
$b
  "$S$C"Modo de uso$S2:
$b$W
	$name -icmp alcance.txt
	$name -tcp F alcance.txt
	$name -tcp N alcance.txt
	$name -udp alcance.txt
	$name -udp all alcance.txt
$NF"
}


## Proceso la entrada

function translate_red(){
	grep "/" $input > "$filt_tmp"
	grep -v "/" $input >> $list_tmp
	for i in $(cat $filt_tmp); do
		red_addr=$(ipcalc -b $i | grep -i "hostmin" | awk '{FS = " "} {print $2}' | cut -d "." -f 1,2)
		red_min=$(ipcalc -b $i | grep -i "hostmin" | awk '{FS = " "} {print $2}' | cut -d "." -f 3)
		red_max=$(ipcalc -b $i | grep -i "hostmax" | awk '{FS = " "} {print $2}' | cut -d "." -f 3)
		host_min=$(ipcalc -b $i | grep -i "hostmin" | sed -e "s/\./ /g"| awk '{FS = " "} {print $5}')
		host_max=$(ipcalc -b $i | grep -i "broadcast" | sed -e "s/\./ /g"| awk '{FS = " "} {print $5}')
		for (( i="$red_min"; i<="$red_max"; i++ )) do
			red="$red_addr.$i"
			for (( x="$host_min"; x<"$host_max"; x++ )) do
				ip="$red.$x"
				echo "$ip" >> $list_tmp
			done
		done
	done
}


## elimino temporales
function cleanup(){
	rm -f $list_tmp $filt_tmp
}


## Ejecucion de pruebas

function test_ping () {
	translate_red
	for i in $(cat $list_tmp); do
   		echo "ping -W 1 -c 1 $i | grep from |  wc -l" >> $icmp_log
		salida=$(ping -W 1 -c 1 $i | tee -a $icmp_log | grep from | wc -l | sed -e "s/0/NO RESPONDE/g" | sed -e "s/1/RESPONDE/g" ) 
		if [ "$salida" == "RESPONDE" ]; then #dio fail
			fail="1"
			echo -e "$b$R    ✘ $W $i $salida"
		else #dio pass
			echo -e "$b$G    ✔ $W $i $salida"
		fi
	done 
	if [ "$fail" == "1" ]; then 
		banner_fail
	else 
		banner_pass
	fi
	cleanup
}


## Escaneos Nmap tcp
function scan_nmap_tcp (){
	translate_red
	IPs=$(cat $list_tmp)
	if [ "$param_2" == "F" ]; then
		sudo nmap -vv -n -sS -Pn --disable-arp-ping -T4 -F -oG "$tcp_grep_100" $IPs | tee "$tcp_log_100" | grep "Timing"
	elif [ "$param_2" == "N" ]; then
		sudo nmap -vv -n -sS -Pn --disable-arp-ping -T4 -oG "$tcp_grep_1000" $IPs | tee "$tcp_log_1000" | grep "Timing"
	elif [ "$param_2" == "all" ]; then
		sudo nmap -vv -n -sS -Pn --disable-arp-ping -T4 -p 1-65535 -oG "$tcp_grep_all" $IPs | tee "$tcp_log_all" | grep "Timing"
	elif [ "$param_2" == "$input" ]; then 
		sudo nmap -vv -n -sS -Pn --disable-arp-ping -T4 -oG "$tcp_grep_1000" $IPs | tee "$tcp_log_1000" | grep "Timing"
	fi
	cleanup
}

## Escaneos Nmap udp
function scan_nmap_udp (){
	translate_red
	IPs=$(cat $list_tmp)
	if [ "$param_2" == "F" ]; then
		sudo nmap -vv -n -sU -Pn --disable-arp-ping --host-timeout 1m  -T4 -F -oG "$udp_grep_100" $IPs | tee "$udp_log_100" | grep "Timing"
	elif [ "$param_2" == "N" ]; then
		sudo nmap -vv -n -sU -Pn --disable-arp-ping --host-timeout 1m  -T4 -oG "$udp_grep_1000" $IPs | tee "$udp_log_1000" | grep "Timing"
	elif [ "$param_2" == "all" ]; then
		sudo nmap -vv -n -sU -Pn --disable-arp-ping --host-timeout 1m  -T4 -p 1-65535 -oG "$udp_grep_all" $IPs | tee "$udp_log_all" | grep "Timing"
	elif [ "$param_2" == "$input" ]; then
		sudo nmap -vv -n -sU -Pn --disable-arp-ping --host-timeout 1m  -T4 -oG "$udp_grep_1000" $IPs | tee "$udp_log_1000" | grep "Timing"
	fi
	cleanup
}


# Detecta fails en archivos .gnmap
function nmap_parser (){	
	grep "Host" $scan | grep -v "filtered/.../" | cut -d' ' -f2,4- | sed -n -e 's/Ignored.*//p' |
	awk '{printf "\n\033[1m    \033[31m✘ \033[39m %-14s RESPONDE \033[31m➔\033[39m %-14s", $1," Total de puertos: " NF-1 "\n"
		$1=""
		for(i=2; i<=NF; i++) { a=a" "$i; }
		split(a,s,",")
		for(e in s) { split(s[e],v,"/")
		printf "	%-5s%s/%-7s%s\n" , v[2], v[3], v[1], v[5]}; a=""}'
}

function report_tcp (){	
	if [ "$param_2" == "F" ]; then
		banner
		banner_inicio
		scan_nmap_tcp
		scan="$tcp_grep_100"
		report=$(nmap_parser "$scan")
		if [ -n "$report" ]; then
			nmap_parser
			banner_fail
		else
			banner_pass
		fi
	elif [ "$param_2" == "N" ]; then
		banner
		banner_inicio
		scan_nmap_tcp
		scan="$tcp_grep_1000"
		report=$(nmap_parser "$scan")
		if [ -n "$report" ]; then
			nmap_parser
			banner_fail
		else
			banner_pass
		fi
	elif [ "$param_2" == "all" ]; then
		banner
		banner_inicio
		scan_nmap_tcp
		scan="$tcp_grep_all"
		report=$(nmap_parser "$scan")
		if [ -n "$report" ]; then
			nmap_parser
			banner_fail
		else	
			banner_pass
		fi	
	elif [ "$param_2" == "$input" ]; then
		banner
		banner_inicio
		scan_nmap_tcp
		scan="$tcp_grep_1000"
		report=$(nmap_parser "$scan")
		if [ -n "$report" ]; then
			nmap_parser
			banner_fail
		else
			banner_pass
		fi
	else 
		echo -e "\n$b$R  [-]$W Parametro no valido$R(╯\`o\`)╯$W︵ ┻━┻ \n"
		exit
	fi
}


function report_udp (){
	if [ "$param_2" == "F" ]; then
		banner
		banner_inicio
		scan_nmap_udp
		scan="$udp_grep_100"
		report=$(nmap_parser "$scan")
		if [ -n "$report" ]; then
			nmap_parser
			banner_fail
		else
			banner_pass
		fi
	elif [ "$param_2" == "N" ]; then
		banner
		banner_inicio
		scan_nmap_udp
		scan="$udp_grep_1000"
		report=$(nmap_parser "$scan")
		if [ -n "$report" ]; then
			nmap_parser
			banner_fail
		else
			banner_pass
		fi
	elif [ "$param_2" == "all" ]; then
		banner
		banner_inicio
		scan_nmap_udp
		scan="$udp_grep_all"
		report=$(nmap_parser "$scan")
		if [ -n "$report" ]; then
			nmap_parser
			banner_fail
		else	
			banner_pass
		fi
	elif [ "$param_2" == "$input" ]; then
		banner
		banner_inicio
		scan_nmap_udp
		scan="$udp_grep_1000"
		report=$(nmap_parser "$scan")
		if [ -n "$report" ]; then
			nmap_parser
			banner_fail
		else
			banner_pass
		fi
	else
		echo -e "\n$b$R  [-]$W Parametro no valido$R(╯\`o\`)╯$W︵ ┻━┻ \n"
		exit
	fi 
}


## Switches
function switch_selector (){
	while [ -n "$1" ]; do
			case "$1" in
			--help) help_menu ;;
			-h) help_menu ;;
			-icmp)
				console_log="icmp-resultados-$hora_log"_"$fecha_log.log"
				banner | tee -a $console_log
				banner_inicio | tee -a $console_log
				test_ping | tee -a $console_log
				shift
				;;
			-tcp)
				console_log="tcp-resultados-$hora_log"_"$fecha_log.log"
				report_tcp "$param_2" | tee -a $console_log
				shift
				;;
			-udp)
				console_log="udp-resultados-$hora_log"_"$fecha_log.log"
				report_udp "$param_2" | tee -a $console_log
				shift
				;;	
			-*)
				echo ""
				echo -e "$b$R  [-]$W Super invalid option $R(╯\`o\`)╯$W︵ ┻━┻"
				echo ""
				shift
				break
				;;
			esac
			shift
		done
}



## Main

if [ -z "$param_1" ]; then
	help_menu
	exit
else
	switch_selector "$param_1" "$param_2"
fi