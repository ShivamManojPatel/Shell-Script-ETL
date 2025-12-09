#!/bin/bash
#Name: Shivam Patel
#Date: 10/28/2025
#Project

#===== Step 1: Transfer file from the source =====#

PRIVATE_KEY="$1"
REMOTE_SERVER="$2"
REMOTE_USER="$3"
REMOTE_FILE="$4"

DEST_DIR="$(pwd)"
DEST_FILE="$DEST_DIR/transaction.csv.bz2"

#Checking parameters
if [ $# -ne 6 ]; then
    echo -e "\e[31mUsage: $0 <private-key> <remote-server> <remote-user> <remote-file> [mysql-user] [mysql-db]\e[0m"
    exit 1
fi

if [ ! -f "$PRIVATE_KEY" ]; then
    echo -e "\e[31mError: Private key not found at $PRIVATE_KEY\e[0m"
    exit 2
fi

#transfering file from server to destination file
scp -i "$PRIVATE_KEY" "${REMOTE_USER}@${REMOTE_SERVER}:${REMOTE_FILE}" "$DEST_FILE"

if [ $? -ne 0 ]; then
    echo -e "\e[31mError transferring file. check your SSH credential or file path\e[0m"
    exit 3
fi

if [ -f "$DEST_FILE" ]; then
    echo "STEP 1..............................Complete"
else
    echo -e "\e[31mError transferring file. check your SSH credential or file path\e[0m"
    exit 4
fi

#===== Step 1: Complete =====#


#===== Step 2: extracting the file =====#
#decompress using bunzip2 (Keeping original)
bunzip2 -k transaction.csv.bz2

if [ $? -ne 0 ]; then
    echo -e "\e[31mError: Failed to decompress\e[0m"
    exit 5
fi

if [ -f transaction.csv ]; then
    echo "STEP 2..............................Complete"
else
    echo -e "\e[31mError: Failed to decompress\e[0m"
    exit 6
fi

#===== Step 2: Complete ====#


#===== Step 3: Remove the header record from the transaction file =====#
tail +2 transaction.csv > temp.csv #tail +2 - displays whole file starting from 2nd line to the end
if [ $? -eq 0 ]; then
    mv temp.csv transaction.csv
    echo "STEP 3..............................Complete"
else
    echo -e "\e[31mError: Failed to remove header\e[0m"
    exit 7
fi

#===== Step 3: Complete =====#


#===== Step 4: Convert all text in the transaction file to lowercase =====#
#===== Converting all the character in lower case using tr =====#
tr '[:upper:]' '[:lower:]' < transaction.csv > temp.csv
cat temp.csv > transaction.csv
rm temp.csv

if [ $? -eq 0 ]; then
    echo "STEP 4..............................Complete"
else
    echo -e "\e[31mError: Failed to convert to lower case\e[0m"
    exit 8
fi

#===== Step 4: Complete =====#


#===== Step 5: Normalize gender field =====#
#/^[ \t]+|[ \t]+$/ is clearing any whitespaces
awk -F',' '{
    g = $5
    g = gensub(/^[ \t]+|[ \t]+$/, "", "g", g)

    if (g=="1" || g=="f" || g=="female") $5="f"
    else if (g=="0" || g=="m" || g=="male") $5="m"
    else $5="u"
    print $0
}' OFS=',' "transaction.csv" > "temp.csv"

if [ $? -eq 0 ]; then
    mv temp.csv transaction.csv
    echo "STEP 5..............................Complete"
else
    echo -e "\e[31mError: Gender Normalization failed\e[0m"
    rm temp.csv
    exit 9
fi

#===== Step 5: Complete =====#


#===== Step 6: Filtering none state records =====#
#/^[ \t]+|[ \t]+$/ is clearing any whitespaces
awk -F',' '{
    s=$12
    gsub(/^[ \t]+|[ \t]+$/, "", s)
    if (s=="" || s=="na") {
        print >> "exception.csv"
    } else {
        print >> "temp.csv"
    }
}' transaction.csv && mv temp.csv transaction.csv

if [ $? -eq 0 ]; then
    echo "STEP 6..............................Complete"
else
    echo -e "\e[31mError! Failed to filter\e[0m"
    exit 10
fi

#===== Step 6: Complete =====#


#===== Step 7: clear $ sign =====#
#/\$/ replace $ with nothing
awk -F',' 'BEGIN{ OFS="," }
{
    gsub(/\$/, "", $6)

    if ($6 ~ /^[0-9.]+$/) {
        $6 = sprintf("%.2f", $6)
    }

    print
}' transaction.csv > temp.csv && mv temp.csv transaction.csv

if [ $? -eq 0 ]; then
    echo "STEP 7..............................Complete"
else
    echo -e "\e[31mError! Failed to to remove $ sign\e[0m"
    exit 11
fi

#===== Step 7: Complete =====#


#===== Step 8: Sort transaction by customer ID =====#
#sorting transaction file using customer ID and delimiter ','
sort -t',' -k1,1 transaction.csv -o temp.csv && mv temp.csv transaction.csv

if [ $? -eq 0 ]; then
    echo "STEP 8..............................Complete"
else
    echo -e "\e[31mError! Failed to sort\e[0m"
    exit 12
fi
#===== Step 8: Complete =====#


#===== Step 9: Generate Summary =====#

awk -F',' '
NR > 1 {
    amt = $6
    total[$1] += amt
    state[$1] = $12
    zip[$1] = $13
    lname[$1] = $3
    fname[$1] = $2
}
END {
    print "customerID,state,zip,lastname,firstname,total_purchase_amount"
    for (id in total) {
        printf "%s,%s,%s,%s,%s,%.2f\n", id, state[id], zip[id], lname[id], fname[id], total[id]
    }
}' transaction.csv > temp.csv

if [ $? -ne 0 ]; then
    echo -e "\e[31mError! Failed to generate summary\e[0m"
    exit 13
fi

sort -t',' -k2,2 -k3,3r -k4,4 -k5,5 temp.csv > summary.csv

if [ $? -eq 0 ]; then
    rm temp.csv
    echo "STEP 9..............................Complete"
else
    echo -e "\e[31mError! Failed to sort summary\e[0m"
    exit 14
fi
#===== Step 9: Complete =====#


#===== Step 10: Generate report =====#
(
echo "Report by: Shivam Patel"
echo "Transaction count report"
echo 
echo "State  Transaction Count"
awk -F',' '
{
    state = toupper($12)
    gsub(/^[ \t]+|[ \t]+$/, "", state)
    if (state != "" && state != "NA")
        count[state]++
}
END{
    for (s in count)
        printf "%-6s %d\n", s, count[s]
}' transaction.csv | sort -k2,2nr -k1,1
) > transaction.rpt

if [ $? -ne 0 ]; then
    echo -e "\e[31mError! Failed to generate transaction count report\e[0m"
    exit 15
fi

(
echo "Report by: Shivam Patel"
echo "Total purchase report"
echo
printf "%-10s %-8s %15s\n" "State" "Gender" "Purchase Amount"
awk -F',' '
{
    state = toupper($12)
    gender = toupper($5)
    amt = $6 + 0
    if (state != "" && gender != "")
        total[state, gender] += amt
}
END{
    for (k in total){
        split(k, a, SUBSEP)
        printf "%-10s %-8s %8.2f\n", a[1], a[2], total[k]
    }
}' transaction.csv | sort -k3,3nr -k1,1 -k2,2
) > purchase.rpt

if [ $? -eq 0 ]; then
    echo "STEP 10.............................Complete"
else
    echo -e "\e[31mError! Failed to generate purchase report\e[0m"
    exit 16
fi
#===== Step 10: Complete =====#

#===== Step 11: Import to database =====#
read -sp "Enter MySql password for user $5: " MYSQL_PWD

mysql -u "$5" -p"$MYSQL_PWD" "$6" << EOF
DROP TABLE IF EXISTS \`transaction\`;
CREATE TABLE \`transaction\` (
    customer_id VARCHAR(20),
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100),
    gender VARCHAR(10),
    purchase_amount DECIMAL(13,2),
    credit_card VARCHAR(25),
    transaction_id VARCHAR(25),
    transaction_date DATE,
    street VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(10),
    zip VARCHAR(10),
    phone VARCHAR(10)
);

DROP TABLE IF EXISTS summary;
CREATE TABLE summary(
    transaction_id VARCHAR(50),
    state VARCHAR(10),
    zip VARCHAR(10),
    last_name VARCHAR(50),
    first_name VARCHAR(50),
    purchase_amount DECIMAL(13,2)
);

EOF

if [ $? -ne 0 ]; then
    echo -e "\e[31mError! Failed to create tables\e[0m"
    exit 17
fi

mysqlimport --local \
    --user="$5" \
    --password="$MYSQL_PWD" \
    --fields-terminated-by=',' \
    --lines-terminated-by='\n' \
    "$6" transaction.csv summary.csv

if [ $? -eq 0 ]; then
    echo "STEP 11.............................Complete"
else
    echo -e "\e[31mError! Failed to upload data to database\e[0m"
    exit 18
fi

#===== Step 11: Complete =====#


#===== Step 12: Remove temporary files =====#

#rm -f transaction.csv.bak && rm -f .* && rm transaction.csv.bz2

if [ $? -eq 0 ]; then
    echo "STEP 12.............................Complete"
else
    echo -e "\e[31mError! Failed to remove temporary files\e[0m"
    exit 19
fi

#===== Step 12: Complete =====#
exit 0
