Project: ETL Processing Script
Course: CSCI 5305 - Linux/Unix System
Name: Shivam Patel


-------------------------------------
How to run the script
-------------------------------------
Usage:
    ./etl.sh (private-key) (remote-server) (remote-user) (remote-file) (mysql-user) (mysql-db)


-------------------------------------
What the script does
-------------------------------------
01. Transfer the remote .csv.bz2 file using scp and your private key.
02. Decompresses the .bz2 file to produce transaction.csv.
03. Remove the header row.
04. Convert all text to lowercase.
05. Standardizes the gender field (m, f, u).
06. Filters missing/invalid states into exception.csv
07. Cleans purchase amount (removes '$' and formats to 2 decimals).
08. Sorts transaction.csv by CustomerID.
09. Creates summary.csv:
    - customerID, state, zip, lastname, firstname, total purchase
    - Sorted by: state, zip DESC, lastname, firstname
10. Generates transaction.rpt:
    - Transaction count per state
    - Sorted by count DESC then state
11. Generates purchase.rpt:
    - Total purchase amount by state/gender
    - Rounded to nearest 100
    - Sorted by amount DESC then state then gender

-------------------------------------
Files Produced by Script
-------------------------------------
- transaction.csv (Cleaned Data)
- exceptions.csv
- summary.csv
- transaction.rpt
- purchase.rpt

-------------------------------------
Notes
-------------------------------------
- Script requires standard Linux tools (awk, sed, tr, sort, scp, bunzip2).
- Script includes error checking and usage statement.
- No hard-coded paths; all arguments supplied at runtime.

-------------------------------------
Check before running script
-------------------------------------
- There should be just 2 file inside the folder. Which are README.txt and etl.sh. all other files should be deleted.
- Remove # from line 321. That line is commented because this project was being uploaded on github.
- Make sure you have a server and there is proper csv file inside a .bz2 compression.
- If you don't have server you should comment step 1 and 2.
- If you dont have csv stored in server but as a bz2 zip. you should comment step 1.
- If you have csv file locally and is not compressed. You should comment step 1 and 2 and add mv <absolute-path-to-file><your-filename>.<extention> transaction.csv before line 65.

