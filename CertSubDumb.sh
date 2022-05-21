green=`tput setaf 2`
yellow=`tput setaf 3`
red=`tput setaf 1`
blue=`tput setaf 4`
magenta=`tput setaf 5`
cyan=`tput setaf 6`
white=`tput setaf 7`
bold=`tput bold`
normal=`tput sgr0`
ORANGE='\033[0;33m'
domain=$1

echo ""

printf "${green}${bold}"
figlet -w 250 -f slant "CertSubDumb"
echo -e "${normal}${yellow}A Script to scrape all subdomains for a domain from CRTSH by @k4k4r07 (https://twitter.com/k4k4r07)"
echo ""
echo ""

function firstLevelDomains(){

	domain=$1
	echo ""
	echo -e "${red}${bold}Collecting First-Level-Domains for $domain"
	echo ""
	while read line; do
		count=$(echo $line | grep -o "\." | wc -l)
		if [[ $count -eq 2 ]]
		then
	  		echo $line >> firstLevelDomains.txt
		fi
	done < InitialDomains.txt
	cat firstLevelDomains.txt >> Subdomains.txt
	echo -e "${ORANGE}${bold}First-Level-Domains for $domain"
	echo ""
	printf "${bold}${white}"
	cat firstLevelDomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo ""
	echo "${green}${bold}[+] Subdomains collected after First-Level Run: $count"
	echo "${magenta}------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
}

function secondLevelDomains(){

	domain=$1
	echo ""
	echo -e "${red}${bold}Collecting Second-Level-Domains for $domain"
	echo ""
	curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' >> secondLevelDomains.txt
	while read line; do
		firstLevelDomain=$line
		echo "${bold}${cyan}Running on $firstLevelDomain"
		curl -s https://crt.sh/?Identity=%.$firstLevelDomain | grep ">*.$firstLevelDomain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$firstLevelDomain" | sort -u | awk 'NF' >> secondLevelDomains.txt
	done < firstLevelDomains.txt
	sort secondLevelDomains.txt | uniq > temp.txt
	cat temp.txt > secondLevelDomains.txt
	rm temp.txt
	cat secondLevelDomains.txt >> Subdomains.txt
	while read line; do
		count=$(echo $line | grep -o "\." | wc -l)
		if [[ $count -eq 3 ]]
		then
	  		echo $line >> temp.txt
		fi
	done < secondLevelDomains.txt
	if [ -s temp.txt ]
	then
		echo ""
	else
		sort Subdomains.txt | uniq > temp.txt
		cat temp.txt > Subdomains.txt
		exit 0
	fi
	cat temp.txt > secondLevelDomains.txt
	echo -e "${ORANGE}${bold}Second-Level-Domains for $domain"
	echo ""
	printf "${bold}${white}"
	cat secondLevelDomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo ""
	echo "${green}${bold}[+] Subdomains collected after Second-Level Run: $count"
	rm temp.txt
	echo "${magenta}------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

}

function thirdLevelDomains(){

	domain=$1
	echo -e "${red}${bold}Collecting Third-Level-Domains for $domain"
	echo ""
	curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' >> thirdLevelDomains.txt
	while read line; do
		secondLevelDomain=$line
		echo "${bold}${yellow}Running on $secondLevelDomain"
		curl -s https://crt.sh/?Identity=%.$secondLevelDomain | grep ">*.$secondLevelDomain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$secondLevelDomain" | sort -u | awk 'NF' >> thirdLevelDomains.txt
	done < secondLevelDomains.txt
	sort thirdLevelDomains.txt | uniq > temp.txt
	cat temp.txt > thirdLevelDomains.txt
	rm temp.txt
	cat thirdLevelDomains.txt >> Subdomains.txt
	while read line; do
		count=$(echo $line | grep -o "\." | wc -l)
		if [[ $count -eq 4 ]]
		then
	  		echo $line >> temp.txt
		fi
	done < thirdLevelDomains.txt
	if [ -s temp.txt ]
	then
		echo "Continue to next level"
	else
		sort Subdomains.txt | uniq > temp.txt
		cat temp.txt > Subdomains.txt
		exit 0
	fi
	cat temp.txt > thirdLevelDomains.txt
	echo -e "${ORANGE}${bold}Third-Level-Domains for $domain"
	echo ""
	printf "${bold}${white}"
	cat thirdLevelDomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo ""
	echo "${green}${bold}[+] Subdomains collected after Third-Level Run: $count"
	rm temp.txt
	echo "${magenta}------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"
}

function fourthLevelDomains(){

	domain=$1
	echo -e "${red}${bold}Collecting Fourth-Level-Domains for $domain"
	echo ""
	curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' >> fourthLevelDomains.txt
	while read line; do
		thirdLevelDomain=$line
		echo "${bold}${cyan}Running on $thirdLevelDomain"
		curl -s https://crt.sh/?Identity=%.$thirdLevelDomain | grep ">*.$thirdLevelDomain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$thirdLevelDomain" | sort -u | awk 'NF' >> fourthLevelDomains.txt
	done < thirdLevelDomains.txt
	sort fourthLevelDomains.txt | uniq > temp.txt
	cat temp.txt > fourthLevelDomains.txt
	rm temp.txt
	cat fourthLevelDomains.txt >> Subdomains.txt
	while read line; do
		count=$(echo $line | grep -o "\." | wc -l)
		if [[ $count -eq 5 ]]
		then
	  		echo $line >> temp.txt
		fi
	done < fourthLevelDomains.txt
	if [ -s temp.txt ]
	then
		echo "Continue to next level"
	else
		sort Subdomains.txt | uniq > temp.txt
		cat temp.txt > Subdomains.txt
		exit 0
	fi
	cat temp.txt > fourthLevelDomains.txt
	echo -e "${ORANGE}${bold}Fourth-Level-Domains for $domain"
	echo ""
	printf "${bold}${white}"
	cat fourthLevelDomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo ""
	echo "${green}${bold}[+] Subdomains collected after Fourth-Level Run: $count"
	rm temp.txt
	echo "${magenta}------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

}


function fifthLevelDomains(){

	domain=$1
	echo -e "${red}${bold}Collecting Fivth-Level-Domains for $domain"
	echo ""
	curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' >> fifthLevelDomains.txt
	while read line; do
		fourthLevelDomains=$line
		echo "${bold}${yellow}Running on $fourthLevelDomains"
		curl -s https://crt.sh/?Identity=%.$fourthLevelDomains | grep ">*.$fourthLevelDomains" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$fourthLevelDomains" | sort -u | awk 'NF' >> fifthLevelDomains.txt
	done < fourthLevelDomains.txt
	sort fifthLevelDomains.txt | uniq > temp.txt
	cat temp.txt > fifthLevelDomains.txt
	rm temp.txt
	cat fifthLevelDomains.txt >> Subdomains.txt
	while read line; do
		count=$(echo $line | grep -o "\." | wc -l)
		if [[ $count -eq 6 ]]
		then
	  		echo $line >> temp.txt
		fi
	done < fifthLevelDomains.txt
	if [ -s temp.txt ]
	then
		echo "Continue to next level"
	else
		sort Subdomains.txt | uniq > temp.txt
		cat temp.txt > Subdomains.txt
		exit 0
	fi
	cat temp.txt > fifthLevelDomains.txt
	echo -e "${ORANGE}${bold}Fifth-Level-Domains for $domain"
	echo ""
	printf "${bold}${white}"
	cat fifthLevelDomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo ""
	echo "${green}${bold}[+] Subdomains collected after Fifth-Level Run: $count"
	rm temp.txt
	echo "${magenta}------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

}


function sixthLevelDomains(){

	domain=$1
	echo -e "${red}${bold}Collecting Sixth-Level-Domains for $domain"
	echo ""
	curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' >> sixthLevelDomains.txt
	while read line; do
		fifthLevelDomains=$line
		echo "${bold}${cyan}Running on $fifthLevelDomains"
		curl -s https://crt.sh/?Identity=%.$fifthLevelDomains | grep ">*.$fifthLevelDomains" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$fifthLevelDomains" | sort -u | awk 'NF' >> sixthLevelDomains.txt
	done < fifthLevelDomains.txt
	sort sixthLevelDomains.txt | uniq > temp.txt
	cat temp.txt > sixthLevelDomains.txt
	rm temp.txt
	cat sixthLevelDomains.txt >> Subdomains.txt
	while read line; do
		count=$(echo $line | grep -o "\." | wc -l)
		if [[ $count -eq 7 ]]
		then
	  		echo $line >> temp.txt
		fi
	done < sixthLevelDomains.txt
	if [ -s temp.txt ]
	then
		echo "Continue to next level"
	else
		sort Subdomains.txt | uniq > temp.txt
		cat temp.txt > Subdomains.txt
		exit 0
	fi
	cat temp.txt > sixthLevelDomains.txt
	echo -e "${ORANGE}${bold}Sixth-Level-Domains for $domain"
	echo ""
	printf "${bold}${white}"
	cat sixthLevelDomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo ""
	printf "${bold}${white}"
	echo "${green}${bold}[+] Subdomains collected after Sixth-Level Run: $count"
	rm temp.txt
	echo "${magenta}------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

}


function seventhLevelDomains(){

	domain=$1
	echo -e "${red}${bold}Collecting Seventh-Level-Domains for $domain"
	echo ""
	curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' >> seventhLevelDomains.txt
	while read line; do
		sixthLevelDomains=$line
		echo "${bold}${yellow}Running on $sixthLevelDomains"
		curl -s https://crt.sh/?Identity=%.$sixthLevelDomains | grep ">*.$sixthLevelDomains" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$sixthLevelDomains" | sort -u | awk 'NF' >> seventhLevelDomains.txt
	done < sixthLevelDomains.txt
	sort seventhLevelDomains.txt | uniq > temp.txt
	cat temp.txt > seventhLevelDomains.txt
	rm temp.txt
	cat seventhLevelDomains.txt >> Subdomains.txt
	while read line; do
		count=$(echo $line | grep -o "\." | wc -l)
		if [[ $count -eq 8 ]]
		then
	  		echo $line >> temp.txt
		fi
	done < seventhLevelDomains.txt
	if [ -s temp.txt ]
	then
		echo "Continue to next level"
	else
		sort Subdomains.txt | uniq > temp.txt
		cat temp.txt > Subdomains.txt
		exit 0
	fi
	cat temp.txt > seventhLevelDomains.txt
	echo -e "${ORANGE}${bold}Seventh-Level-Domains for $domain"
	echo ""
	printf "${bold}${white}"
	cat seventhLevelDomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo ""
	echo "${green}${bold}[+] Subdomains collected after Seventh-Level Run: $count"
	rm temp.txt
	echo "${magenta}------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

}


function eighthLevelDomains(){

	domain=$1
	echo -e "${red}${bold}Collecting Eighth-Level-Domains for $domain"
	echo ""
	curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' >> eighthLevelDomains.txt
	while read line; do
		seventhLevelDomains=$line
		echo "${bold}${cyan}Running on $seventhLevelDomains"
		curl -s https://crt.sh/?Identity=%.$seventhLevelDomains | grep ">*.$seventhLevelDomains" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$seventhLevelDomains" | sort -u | awk 'NF' >> eighthLevelDomains.txt
	done < seventhLevelDomains.txt
	sort eighthLevelDomains.txt | uniq > temp.txt
	cat temp.txt > eighthLevelDomains.txt
	rm temp.txt
	cat eighthLevelDomains.txt >> Subdomains.txt
	while read line; do
		count=$(echo $line | grep -o "\." | wc -l)
		if [[ $count -eq 9 ]]
		then
	  		echo $line >> temp.txt
		fi
	done < eighthLevelDomains.txt
	if [ -s temp.txt ]
	then
		echo "Continue to next level"
	else
		sort Subdomains.txt | uniq > temp.txt
		cat temp.txt > Subdomains.txt
		exit 0

	fi
	cat temp.txt > eighthLevelDomains.txt
	echo -e "${ORANGE}${bold}Eighth-Level-Domains for $domain"
	echo ""
	printf "${bold}${white}"
	cat eighthLevelDomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo ""
	echo "${green}${bold}[+] Subdomains collected after Eighth-Level Run: $count"
	rm temp.txt
	echo "${magenta}------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

}


function ninthLevelDomains(){

	domain=$1
	echo -e "${red}${bold}Collecting Ninth-Level-Domains for $domain"
	echo ""
	curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' >> ninthLevelDomains.txt
	while read line; do
		eighthLevelDomains=$line
		echo "${bold}${yellow}Running on $eighthLevelDomains"
		curl -s https://crt.sh/?Identity=%.$eighthLevelDomains | grep ">*.$eighthLevelDomains" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$eighthLevelDomains" | sort -u | awk 'NF' >> ninthLevelDomains.txt
	done < eighthLevelDomains.txt
	sort ninthLevelDomains.txt | uniq > temp.txt
	cat temp.txt > ninthLevelDomains.txt
	rm temp.txt
	cat ninthLevelDomains.txt >> Subdomains.txt
	while read line; do
		count=$(echo $line | grep -o "\." | wc -l)
		if [[ $count -eq 10 ]]
		then
	  		echo $line >> temp.txt
		fi
	done < ninthLevelDomains.txt
	if [ -s temp.txt ]
	then
		echo "Continue to next level"
	else
		sort Subdomains.txt | uniq > temp.txt
		cat temp.txt > Subdomains.txt
		exit 0
	fi
	cat temp.txt > ninthLevelDomains.txt
	echo -e "${ORANGE}${bold}Ninth-Level-Domains for $domain"
	echo ""
	printf "${bold}${white}"
	cat ninthLevelDomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo ""
	echo "${green}${bold}[+] Subdomains collected after Ninth-Level Run: $count"
	rm temp.txt
	echo "${magenta}------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

}

function tenthLevelDomains(){

	domain=$1
	echo -e "${red}${bold}Collecting Tenth-Level-Domains for $domain"
	curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' >> tenthLevelDomains.txt
	while read line; do
		ninthLevelDomains=$line
		echo "${bold}${cyan}Running on $ninthLevelDomains"
		curl -s https://crt.sh/?Identity=%.$ninthLevelDomains | grep ">*.$ninthLevelDomains" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$ninthLevelDomains" | sort -u | awk 'NF' >> tenthLevelDomains.txt
	done < ninthLevelDomains.txt
	sort tenthLevelDomains.txt | uniq > temp.txt
	cat temp.txt > tenthLevelDomains.txt
	rm temp.txt
	cat tenthLevelDomains.txt >> Subdomains.txt
	while read line; do
		count=$(echo $line | grep -o "\." | wc -l)
		if [[ $count -eq 11 ]]
		then
	  		echo $line >> temp.txt
		fi
	done < tenthLevelDomains.txt
	if [ -s temp.txt ]
	then
		echo "Continue to next level"
	else
		sort Subdomains.txt | uniq > temp.txt
		cat temp.txt > Subdomains.txt
		exit 0
	fi
	cat temp.txt > tenthLevelDomains.txt
	echo "Tenth-Level-Domains for $domain"
	echo ""
	printf "${bold}${white}"
	cat tenthLevelDomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo "${green}${bold}[+] Subdomains collected after Tenth-Level Run: $count"
	echo ""
	rm temp.txt
	echo "${magenta}------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------"

}

function cleanUp(){
	rm Subdomains.txt 2> /dev/null
	rm firstLevelDomains.txt 2> /dev/null
	rm secondLevelDomains.txt 2> /dev/null
	rm thirdLevelDomains.txt 2> /dev/null
	rm fourthLevelDomains.txt 2> /dev/null
	rm fifthLevelDomains.txt 2> /dev/null
	rm sixthLevelDomains.txt 2> /dev/null
	rm seventhLevelDomains.txt 2> /dev/null
	rm eighthLevelDomains.txt 2> /dev/null
	rm ninthLevelDomains.txt 2> /dev/null
	rm tenthLevelDomains.txt 2> /dev/null
	rm temp.txt 2> /dev/null
}


function main(){

	cleanUp
	echo "${bold}${cyan}Collecting Initial Domains for $domain"
	echo ""
	curl -s https://crt.sh/?Identity=%.$domain | grep ">*.$domain" | sed 's/<[/]*[TB][DR]>/\n/g' | grep -vE "<|^[\*]*[\.]*$domain" | sort -u | awk 'NF' > InitialDomains.txt
	cat InitialDomains.txt > Subdomains.txt
	count=$(cat Subdomains.txt | wc -l)
	echo ""
	echo "${green}${bold}[+] Subdomains collected after Initial Run: $count"
	firstLevelDomains "$domain"
	secondLevelDomains "$domain"
	thirdLevelDomains "$domain"
	fourthLevelDomains "$domain"
	fifthLevelDomains "$domain"
	sixthLevelDomains "$domain"
	seventhLevelDomains "$domain"
	eighthLevelDomains "$domain"
	ninthLevelDomains "$domain"
	tenthLevelDomains "$domain"

}



main
